// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Login with email/password
  Future<bool> login(
    String email,
    String password, [
    bool? forceDriverCheck,
  ]) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.loginWithEmail(email, password);
      if (user != null) {
        _user = user;

        if (forceDriverCheck != null && user.isDriver != forceDriverCheck) {
          _errorMessage = forceDriverCheck
              ? 'This account is not registered as a driver'
              : 'This account is not registered as a rider';
          _user = null;
          notifyListeners();
          return false;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception: ')
          ? e.toString().split('Exception: ').last
          : e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required bool isDriver,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        isDriver: isDriver,
      );
      _user = user;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().split('Exception: ').last;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.loginWithGoogle();
      if (user != null) {
        _user = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Update user profile
  Future<bool> updateUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? vehicleModel,
    String? licensePlate,
    bool? isDriver, // Optional: allow role change (admin only usually)
  }) async {
    if (_user == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // Prepare update map – only include non-null values
      final Map<String, dynamic> updates = {};

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (email != null) updates['email'] = email;
      if (phone != null) updates['phone'] = phone;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (vehicleModel != null) updates['vehicleModel'] = vehicleModel;
      if (licensePlate != null) updates['licensePlate'] = licensePlate;
      if (isDriver != null) updates['isDriver'] = isDriver;

      if (updates.isEmpty) {
        _setLoading(false);
        return true; // Nothing to update
      }

      // Update in Firestore
      await _firestore.collection('users').doc(_user!.id).update(updates);

      // Update local user object
      _user = _user!.copyWith(
        name: firstName != null || lastName != null
            ? '${firstName ?? _user!.firstName} ${lastName ?? _user!.lastName}'
            : _user!.name,
        email: email ?? _user!.email,
        phone: phone ?? _user!.phone,
        photoUrl: profileImageUrl ?? _user!.photoUrl,
        vehicleModel: vehicleModel ?? _user!.vehicleModel,
        licensePlate: licensePlate ?? _user!.licensePlate,
        isDriver: isDriver ?? _user!.isDriver,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get current user on app start
  Future<void> checkCurrentUser() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Send password reset
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send reset email';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
