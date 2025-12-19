// services/ride_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent rides for a user (rider or driver)
  Future<List<Ride>> getRecentRides(String userId,
      {bool isDriver = false}) async {
    try {
      final query = _firestore
          .collection('rides')
          .where(isDriver ? 'driverId' : 'riderId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load recent rides: $e');
    }
  }

  // Get available rides nearby (for drivers)
  Future<List<Ride>> getAvailableRides(Position currentLocation) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('status', isEqualTo: RideStatus.requested.name)
          .where('driverId', isNull: true)
          .limit(50)
          .get();

      final rides =
          snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();

      // Sort by distance (optional, requires geo fields)
      // For real geo-search, use GeoFirestore or Firestore Geo queries

      return rides;
    } catch (e) {
      throw Exception('Failed to load available rides: $e');
    }
  }

  // Rider requests a ride
  Future<Ride> requestRide({
    required String riderId,
    required String riderName,
    required String? riderPhone,
    required String? riderPhotoUrl,
    required double riderRating,
    required int riderTotalRides,
    required String pickup,
    required String destination,
    required double distance,
    required int durationMinutes,
    required double fare,
  }) async {
    try {
      final ref = _firestore.collection('rides').doc();
      final rideId = ref.id;

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
        riderRating: riderRating,
        riderTotalRides: riderTotalRides,
      );

      await ref.set(ride.toJson());
      return ride;
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  // Driver accepts a ride
  Future<bool> acceptRide(String rideId, String driverId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': driverId,
        'status': RideStatus.accepted.name,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      throw Exception('Failed to accept ride: $e');
    }
  }

  // Update ride status
  Future<bool> updateRideStatus(String rideId, RideStatus status) async {
    try {
      final updates = {
        'status': status.name,
      };
      if (status == RideStatus.pickedUp) {
        updates['pickedUpAt'] = FieldValue.serverTimestamp() as String;
      } else if (status == RideStatus.completed) {
        updates['completedAt'] = FieldValue.serverTimestamp() as String;
      }

      await _firestore.collection('rides').doc(rideId).update(updates);
      return true;
    } catch (e) {
      throw Exception('Failed to update status: $e');
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
      return true;
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }
}
