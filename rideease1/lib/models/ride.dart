// models/ride.dart
import 'package:flutter/material.dart';

enum RideStatus {
  requested,
  accepted,
  pickedUp,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RideStatus.requested:
        return 'Finding Driver';
      case RideStatus.accepted:
        return 'Driver On The Way';
      case RideStatus.pickedUp:
        return 'Picked Up';
      case RideStatus.inProgress:
        return 'In Progress';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case RideStatus.requested:
        return Colors.orange;
      case RideStatus.accepted:
        return Colors.blue;
      case RideStatus.pickedUp:
      case RideStatus.inProgress:
        return Colors.green;
      case RideStatus.completed:
        return Colors.purple;
      case RideStatus.cancelled:
        return Colors.red;
    }
  }
}

class Ride {
  final String id;
  final String riderId;
  final String? driverId;

  // Addresses
  final String pickupAddress;
  final String destinationAddress;

  // Trip details
  final double distance;
  final int durationMinutes;
  final double fare;

  // Status & timestamps
  final RideStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? completedAt;

  // NEW: Passenger info (this fixes your error!)
  final String riderName;
  final String? riderPhone;
  final String? riderPhotoUrl;
  final double riderRating;
  final int riderTotalRides;

  const Ride({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distance,
    required this.durationMinutes,
    required this.fare,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.completedAt,
    required this.riderName,
    this.riderPhone,
    this.riderPhotoUrl,
    this.riderRating = 4.8,
    this.riderTotalRides = 0,
  });

  // CopyWith
  Ride copyWith({
    String? id,
    String? riderId,
    String? driverId,
    String? pickupAddress,
    String? destinationAddress,
    double? distance,
    int? durationMinutes,
    double? fare,
    RideStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? completedAt,
    String? riderName,
    String? riderPhone,
    String? riderPhotoUrl,
    double? riderRating,
    int? riderTotalRides,
  }) {
    return Ride(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      distance: distance ?? this.distance,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      completedAt: completedAt ?? this.completedAt,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      riderPhotoUrl: riderPhotoUrl ?? this.riderPhotoUrl,
      riderRating: riderRating ?? this.riderRating,
      riderTotalRides: riderTotalRides ?? this.riderTotalRides,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'riderId': riderId,
        'driverId': driverId,
        'pickupAddress': pickupAddress,
        'destinationAddress': destinationAddress,
        'distance': distance,
        'durationMinutes': durationMinutes,
        'fare': fare,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'pickedUpAt': pickedUpAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'riderName': riderName,
        'riderPhone': riderPhone,
        'riderPhotoUrl': riderPhotoUrl,
        'riderRating': riderRating,
        'riderTotalRides': riderTotalRides,
      };

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'] as String,
        riderId: json['riderId'] as String,
        driverId: json['driverId'] as String?,
        pickupAddress: json['pickupAddress'] as String,
        destinationAddress: json['destinationAddress'] as String,
        distance: (json['distance'] as num).toDouble(),
        durationMinutes: json['durationMinutes'] as int,
        fare: (json['fare'] as num).toDouble(),
        status: RideStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RideStatus.requested,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        acceptedAt: json['acceptedAt'] != null
            ? DateTime.parse(json['acceptedAt'])
            : null,
        pickedUpAt: json['pickedUpAt'] != null
            ? DateTime.parse(json['pickedUpAt'])
            : null,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        riderName: json['riderName'] as String? ?? 'Passenger',
        riderPhone: json['riderPhone'] as String?,
        riderPhotoUrl: json['riderPhotoUrl'] as String?,
        riderRating: (json['riderRating'] as num?)?.toDouble() ?? 4.8,
        riderTotalRides: json['riderTotalRides'] as int? ?? 0,
      );

  @override
  String toString() =>
      'Ride(id: $id, rider: $riderName, status: $status, fare: ₱$fare)';
}
