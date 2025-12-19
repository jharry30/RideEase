// models/notification.dart
import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? rideId; // optional: link to ride
  final NotificationType type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.rideId,
    this.type = NotificationType.info,
  });

  // REQUIRED: copyWith method
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? rideId,
    NotificationType? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      rideId: rideId ?? this.rideId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'rideId': rideId,
    'type': type.name,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        rideId: json['rideId'] as String?,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.info,
        ),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum NotificationType {
  info,
  ride,
  promo,
  warning;

  Color get color {
    switch (this) {
      case NotificationType.info:
        return const Color(0xFF2196F3);
      case NotificationType.ride:
        return const Color(0xFF4CAF50);
      case NotificationType.promo:
        return const Color(0xFFFF9800);
      case NotificationType.warning:
        return const Color(0xFFF44336);
    }
  }
}
