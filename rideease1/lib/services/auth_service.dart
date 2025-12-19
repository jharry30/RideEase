// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Correct way in google_sign_in ^6.0.0+
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      // No more `scopes:` in constructor!
      // If you need server-side verification on iOS/web, add:
      // serverClientId: 'your-web-client-id.apps.googleusercontent.com',
      );

  // Email/Password Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserFromFirebaseUser(credential.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Email Registration
  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String phone = '',
    required bool isDriver,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        id: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        isDriver: isDriver,
        isAdmin: false,
      );

      await _firestore.collection('users').doc(user.id).set(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign-In – Fixed for google_sign_in ^6.2.1
  Future<User?> loginWithGoogle() async {
    try {
      // This triggers the native Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = authResult.user!;

      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        return User.fromJson(userDoc.data()!);
      }

      // Create new user in Firestore
      final displayName = firebaseUser.displayName ?? 'User';
      final parts = displayName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : 'User';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final newUser = User(
        id: firebaseUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        isDriver: false,
        isAdmin: false,
        profileImageUrl: firebaseUser.photoURL,
      );

      await _firestore
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toJson());
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Logout - Enhanced for complete sign out
  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect(); // Disconnect Google account
      await _googleSignIn.signOut(); // Sign out from Google
      await _firebaseAuth.signOut(); // Sign out from Firebase
    } catch (e) {
      // Optional: log error, but don't rethrow to avoid crashing app on logout
      debugPrint('Logout error: $e');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirebaseUser(firebaseUser);
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Helper
  Future<User> _getUserFromFirebaseUser(firebase_auth.User firebaseUser) async {
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }

    // Fallback: create missing user
    final parts = (firebaseUser.displayName ?? 'User User').split(' ');
    final user = User(
      id: firebaseUser.uid,
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      isDriver: false,
      isAdmin: false,
      profileImageUrl: firebaseUser.photoURL,
    );
    await _firestore.collection('users').doc(user.id).set(user.toJson());
    return user;
  }
}
