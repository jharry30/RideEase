// models/support_ticket.dart
enum TicketStatus { open, inProgress, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? rideId;
  final List<TicketMessage> messages;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.description,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    required this.createdAt,
    this.resolvedAt,
    this.rideId,
    this.messages = const [],
  });

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? subject,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? rideId,
    List<TicketMessage>? messages,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rideId: rideId ?? this.rideId,
      messages: messages ?? this.messages,
    );
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    userEmail: json['userEmail'] as String,
    subject: json['subject'] as String,
    description: json['description'] as String,
    status: TicketStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => TicketStatus.open,
    ),
    priority: TicketPriority.values.firstWhere(
      (e) => e.name == json['priority'],
      orElse: () => TicketPriority.medium,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'] as String)
        : null,
    rideId: json['rideId'] as String?,
    messages:
        (json['messages'] as List<dynamic>?)
            ?.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'subject': subject,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
    'rideId': rideId,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}

class TicketMessage {
  final String id;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final String message;
  final DateTime timestamp;

  const TicketMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.isAdmin = false,
    required this.message,
    required this.timestamp,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    id: json['id'] as String,
    senderId: json['senderId'] as String,
    senderName: json['senderName'] as String,
    isAdmin: json['isAdmin'] as bool? ?? false,
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'isAdmin': isAdmin,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
  };
}
