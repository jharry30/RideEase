// models/announcement.dart
import 'package:flutter/material.dart';

enum AnnouncementPriority { low, medium, high, urgent }

extension AnnouncementPriorityX on AnnouncementPriority {
  Color get color {
    switch (this) {
      case AnnouncementPriority.low:
        return const Color(0xFF4CAF50); // Green
      case AnnouncementPriority.medium:
        return const Color(0xFFFF9800); // Orange
      case AnnouncementPriority.high:
        return const Color(0xFFF44336); // Red
      case AnnouncementPriority.urgent:
        return const Color(0xFFB00020); // Dark Red
    }
  }

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class Announcement {
  final String id;
  final String title;
  final String message;
  final AnnouncementPriority priority;
  final String? targetAudience; // 'rider', 'driver', or null = all
  final DateTime createdAt;
  final DateTime? expiryDate;
  final bool isActive;

  const Announcement({
    required this.id,
    required this.title,
    required this.message,
    this.priority = AnnouncementPriority.medium,
    this.targetAudience,
    required this.createdAt,
    this.expiryDate,
    this.isActive = true,
  });

  Announcement copyWith({
    String? id,
    String? title,
    String? message,
    AnnouncementPriority? priority,
    String? targetAudience,
    DateTime? createdAt,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      targetAudience: targetAudience ?? this.targetAudience,
      createdAt: createdAt ?? this.createdAt,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    priority: AnnouncementPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => AnnouncementPriority.medium,
    ),
    targetAudience: json['targetAudience'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiryDate: json['expiryDate'] != null
        ? DateTime.parse(json['expiryDate'] as String)
        : null,
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'priority': priority.name,
    'targetAudience': targetAudience,
    'createdAt': createdAt.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'isActive': isActive,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Announcement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
