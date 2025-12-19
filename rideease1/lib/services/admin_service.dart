// services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_stats.dart';
import '../models/user.dart';
import '../models/ride.dart';
import '../models/support_ticket.dart';
import '../models/dispute.dart';
import '../models/promo_code.dart';
import '../models/announcement.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to safely cast data
  Map<String, dynamic> _dataFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception('Document does not exist');
    return data as Map<String, dynamic>;
  }

  // Dashboard Stats
  Future<AdminStats> getDashboardStats() async {
    try {
      final usersSnap = await _firestore.collection('users').get();
      final ridersCount = usersSnap.docs.where((d) {
        final data = _dataFromSnapshot(d);
        return !(data['isDriver'] as bool? ?? false);
      }).length;
      final driversCount = usersSnap.docs.where((d) {
        final data = _dataFromSnapshot(d);
        return data['isDriver'] as bool? ?? false;
      }).length;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final ridesSnap = await _firestore
          .collection('rides')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .get();

      int completedToday = 0;
      int cancelledToday = 0;
      int activeRides = 0;
      double todayRevenue = 0.0;

      for (var doc in ridesSnap.docs) {
        final data = _dataFromSnapshot(doc);
        final status = data['status'] as String?;

        if (status == RideStatus.completed.name) {
          completedToday++;
          todayRevenue += (data['fare'] as num?)?.toDouble() ?? 0.0;
        } else if (status == RideStatus.cancelled.name) {
          cancelledToday++;
        } else if (status == RideStatus.inProgress.name ||
            status == RideStatus.pickedUp.name) {
          activeRides++;
        }
      }

      final pendingDrivers = usersSnap.docs.where((d) {
        final data = _dataFromSnapshot(d);
        return (data['isDriver'] as bool? ?? false) &&
            (data['isVerified'] as bool? ?? true) == false;
      }).length;

      final disputesSnap = await _firestore
          .collection('disputes')
          .where('status', isEqualTo: 'pending')
          .get();
      final ticketsSnap = await _firestore
          .collection('support_tickets')
          .where('status', isEqualTo: 'open')
          .get();

      return AdminStats(
        totalUsers: usersSnap.size,
        totalRiders: ridersCount,
        totalDrivers: driversCount,
        activeRides: activeRides,
        completedRidesToday: completedToday,
        cancelledRidesToday: cancelledToday,
        todayRevenue: todayRevenue,
        pendingVerifications: pendingDrivers,
        unresolvedDisputes: disputesSnap.size,
        openTickets: ticketsSnap.size,
      );
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  // Get All Users
  Future<List<User>> getAllUsers(
      {String? searchQuery, String? userType}) async {
    try {
      Query query = _firestore.collection('users');

      if (userType == 'rider') {
        query = query.where('isDriver', isEqualTo: false);
      } else if (userType == 'driver') {
        query = query.where('isDriver', isEqualTo: true);
      }

      final snapshot = await query.get();
      var users = snapshot.docs
          .map((doc) => User.fromJson(_dataFromSnapshot(doc)))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        users = users.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          return fullName.contains(q) ||
              user.email.toLowerCase().contains(q) ||
              user.phone.contains(q);
        }).toList();
      }

      return users;
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<void> suspendUser(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'isSuspended': true});
  }

  Future<void> activateUser(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'isSuspended': false});
  }

  // Pending Driver Verifications
  Future<List<User>> getPendingDriverVerifications() async {
    try {
      final snap = await _firestore
          .collection('users')
          .where('isDriver', isEqualTo: true)
          .where('isVerified', isEqualTo: false)
          .get();

      return snap.docs
          .map((doc) => User.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load pending drivers: $e');
    }
  }

  Future<void> approveDriver(String driverId, String notes) async {
    await _firestore.collection('users').doc(driverId).update({
      'isVerified': true,
      'verificationNotes': notes,
      'verifiedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectDriver(String driverId, String reason) async {
    await _firestore.collection('users').doc(driverId).update({
      'isVerified': false,
      'verificationStatus': 'rejected',
      'verificationNotes': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  // Recent Rides
  Future<List<Ride>> getRecentRides() async {
    try {
      final snap = await _firestore
          .collection('rides')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snap.docs
          .map((doc) => Ride.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load rides: $e');
    }
  }

  Future<void> cancelRide(String rideId, String reason) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': RideStatus.cancelled.name,
      'cancelReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // Disputes
  Future<List<Dispute>> getDisputes() async {
    try {
      final snap = await _firestore
          .collection('disputes')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => Dispute.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load disputes: $e');
    }
  }

  Future<void> resolveDispute(String id, String resolution) async {
    await _firestore.collection('disputes').doc(id).update({
      'status': 'resolved',
      'resolution': resolution,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  // Support Tickets
  Future<List<SupportTicket>> getSupportTickets() async {
    try {
      final snap = await _firestore
          .collection('support_tickets')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => SupportTicket.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load tickets: $e');
    }
  }

  Future<void> resolveTicket(String id, String resolution) async {
    await _firestore.collection('support_tickets').doc(id).update({
      'status': 'resolved',
      'resolution': resolution,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTicketMessage(String id, String message) async {
    await _firestore.collection('support_tickets').doc(id).update({
      'messages': FieldValue.arrayUnion([
        {
          'message': message,
          'senderId': 'admin',
          'senderName': 'Admin',
          'isAdmin': true,
          'timestamp': FieldValue.serverTimestamp(),
        }
      ]),
    });
  }

  // Promo Codes
  Future<List<PromoCode>> getPromoCodes() async {
    try {
      final snap = await _firestore.collection('promo_codes').get();
      return snap.docs
          .map((doc) => PromoCode.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load promos: $e');
    }
  }

  Future<void> createPromoCode(PromoCode promo) async {
    await _firestore
        .collection('promo_codes')
        .doc(promo.id)
        .set(promo.toJson());
  }

  Future<void> deactivatePromoCode(String id) async {
    await _firestore
        .collection('promo_codes')
        .doc(id)
        .update({'isActive': false});
  }

  // Announcements
  Future<List<Announcement>> getAnnouncements() async {
    try {
      final snap = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs
          .map((doc) => Announcement.fromJson(_dataFromSnapshot(doc)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load announcements: $e');
    }
  }

  Future<void> createAnnouncement(Announcement a) async {
    final ref = _firestore.collection('announcements').doc();
    await ref.set(a.copyWith(id: ref.id).toJson());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }
}
