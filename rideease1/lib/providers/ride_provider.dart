// providers/ride_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride.dart';

class RideProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Ride? _currentRide;
  Ride? _activeRide;
  List<Ride> _availableRides = [];
  List<Ride> _pastRides = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _availableRidesSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _activeRideSubscription;

  bool _isLoading = false;
  String? _error;

  // Getters
  Ride? get currentRide => _currentRide;
  Ride? get activeRide => _activeRide;
  List<Ride> get availableRides => List.unmodifiable(_availableRides);
  List<Ride> get pastRides => List.unmodifiable(_pastRides);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveRide => _currentRide != null || _activeRide != null;

  // Rider: Request a ride
  Future<bool> requestRide({
    required String riderId,
    required String riderName,
    required String? riderPhone,
    required String? riderPhotoUrl,
    required String pickup,
    required String destination,
    required double distance,
    required int durationMinutes,
    required double fare,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final rideRef = _firestore.collection('rides').doc();
      final rideId = rideRef.id;

      final ride = Ride(
        id: rideId,
        riderId: riderId,
        pickupAddress: pickup,
        destinationAddress: destination,
        distance: distance,
        durationMinutes: durationMinutes,
        fare: fare,
        status: RideStatus.requested,
        createdAt: DateTime.now(),
        riderName: riderName,
        riderPhone: riderPhone,
        riderPhotoUrl: riderPhotoUrl,
      );

      await rideRef.set(ride.toJson());
      _currentRide = ride;
      notifyListeners();

      _listenToCurrentRide(rideId);
      return true;
    } catch (e) {
      _error = 'Failed to request ride';
      debugPrint(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Driver: Accept ride
  Future<bool> acceptRide(String rideId, String driverId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final rideDoc =
            await transaction.get(_firestore.collection('rides').doc(rideId));
        if (!rideDoc.exists) throw 'Ride not found';
        if (rideDoc['status'] != RideStatus.requested.name) {
          throw 'Ride no longer available';
        }

        transaction.update(rideDoc.reference, {
          'driverId': driverId,
          'status': RideStatus.accepted.name,
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });

      final ride = _availableRides.firstWhere((r) => r.id == rideId);
      _activeRide = ride.copyWith(
        driverId: driverId,
        status: RideStatus.accepted,
        acceptedAt: DateTime.now(),
      );
      _availableRides.removeWhere((r) => r.id == rideId);

      _listenToActiveRide(rideId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to accept ride';
      debugPrint(e.toString());
      return false;
    }
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, RideStatus newStatus) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.name,
      };
      if (newStatus == RideStatus.pickedUp) {
        updates['pickedUpAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == RideStatus.completed) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('rides').doc(rideId).update(updates);

      final updatedRide =
          (_currentRide?.id == rideId ? _currentRide : _activeRide)
              ?.copyWith(status: newStatus);

      if (_currentRide?.id == rideId) {
        _currentRide = updatedRide;
        if (newStatus == RideStatus.completed ||
            newStatus == RideStatus.cancelled) {
          _currentRide = null;
        }
      }
      if (_activeRide?.id == rideId) {
        _activeRide = updatedRide;
        if (newStatus == RideStatus.completed ||
            newStatus == RideStatus.cancelled) {
          _activeRide = null;
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Status update failed';
      return false;
    }
  }

  // Listen for new ride requests (Drivers only)
  void startListeningForRides() {
    stopListeningForRides(); // Prevent duplicates

    _availableRidesSubscription = _firestore
        .collection('rides')
        .where('status', isEqualTo: RideStatus.requested.name)
        .where('driverId', isNull: true)
        .snapshots()
        .listen((snapshot) async {
      final List<Ride> rides = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final riderDoc = await _firestore
            .collection('users')
            .doc(data['riderId'] as String)
            .get();
        final riderData = riderDoc.data() ?? {};

        final ride = Ride.fromJson({
          ...data,
          'riderName':
              riderData['firstName'] != null && riderData['lastName'] != null
                  ? '${riderData['firstName']} ${riderData['lastName']}'
                  : 'Passenger',
          'riderPhotoUrl': riderData['profileImageUrl'] as String?,
          'riderRating': (riderData['rating'] as num?)?.toDouble() ?? 4.8,
          'riderTotalRides': riderData['totalRides'] as int? ?? 0,
        });
        rides.add(ride);
      }

      _availableRides = rides;
      notifyListeners();
    }, onError: (e) => debugPrint('Ride listener error: $e'));
  }

  // Stop listening for new rides
  void stopListeningForRides() {
    _availableRidesSubscription?.cancel();
    _availableRidesSubscription = null;
  }

  // Listen to active ride (driver) or current (rider) ride updates
  void _listenToActiveRide(String rideId) {
    _activeRideSubscription?.cancel();
    _activeRideSubscription =
        _firestore.collection('rides').doc(rideId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _activeRide = Ride.fromJson(doc.data()!);
        notifyListeners();
      }
    });
  }

  void _listenToCurrentRide(String rideId) {
    _activeRideSubscription?.cancel();
    _activeRideSubscription =
        _firestore.collection('rides').doc(rideId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        _currentRide = Ride.fromJson(doc.data()!);
        notifyListeners();
      }
    });
  }

  // Load ride history
  Future<void> loadPastRides(String userId, {bool isDriver = false}) async {
    _setLoading(true);
    try {
      final query = _firestore
          .collection('rides')
          .where(isDriver ? 'driverId' : 'riderId', isEqualTo: userId)
          .where('status',
              whereIn: [RideStatus.completed.name, RideStatus.cancelled.name])
          .orderBy('createdAt', descending: true)
          .limit(50);

      final snapshot = await query.get();
      _pastRides =
          snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load history';
    } finally {
      _setLoading(false);
    }
  }

  // Cancel ride
  Future<bool> cancelRide(String rideId, String reason) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.cancelled.name,
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (_currentRide?.id == rideId) _currentRide = null;
      if (_activeRide?.id == rideId) _activeRide = null;
      _availableRides.removeWhere((r) => r.id == rideId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all data
  void clear() {
    stopListeningForRides();
    _activeRideSubscription?.cancel();
    _currentRide = _activeRide = null;
    _availableRides.clear();
    _pastRides.clear();
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}
