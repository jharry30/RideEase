// models/dispute.dart
enum DisputeType { payment, safety, route, behavior, other }

enum DisputeStatus { pending, investigating, resolved, closed }

class Dispute {
  final String id;
  final String rideId;
  final String reporterId;
  final String reporterName;
  final String reportedId;
  final String reportedName;
  final DisputeType type;
  final DisputeStatus status;
  final String description;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final String? adminNotes;

  const Dispute({
    required this.id,
    required this.rideId,
    required this.reporterId,
    required this.reporterName,
    required this.reportedId,
    required this.reportedName,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
    this.adminNotes,
  });

  Dispute copyWith({
    String? id,
    String? rideId,
    String? reporterId,
    String? reporterName,
    String? reportedId,
    String? reportedName,
    DisputeType? type,
    DisputeStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? resolution,
    String? adminNotes,
  }) {
    return Dispute(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reportedId: reportedId ?? this.reportedId,
      reportedName: reportedName ?? this.reportedName,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  factory Dispute.fromJson(Map<String, dynamic> json) => Dispute(
    id: json['id'] as String,
    rideId: json['rideId'] as String,
    reporterId: json['reporterId'] as String,
    reporterName: json['reporterName'] as String,
    reportedId: json['reportedId'] as String,
    reportedName: json['reportedName'] as String,
    type: DisputeType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => DisputeType.other,
    ),
    status: DisputeStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => DisputeStatus.pending,
    ),
    description: json['description'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'] as String)
        : null,
    resolution: json['resolution'] as String?,
    adminNotes: json['adminNotes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'rideId': rideId,
    'reporterId': reporterId,
    'reporterName': reporterName,
    'reportedId': reportedId,
    'reportedName': reportedName,
    'type': type.name,
    'status': status.name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'resolution': resolution,
    'adminNotes': adminNotes,
  };
}
