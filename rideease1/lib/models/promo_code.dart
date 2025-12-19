// models/promo_code.dart
enum PromoType { percentage, fixedAmount }

extension PromoTypeX on PromoType {
  String get displayName =>
      name == 'percentage' ? 'Percentage Off' : 'Fixed Discount';
}

class PromoCode {
  final String id;
  final String code;
  final PromoType type;
  final double value;
  final int? usageLimit;
  final int usageCount;
  final DateTime? expiryDate;
  final bool isActive;
  final String? userType; // 'rider', 'driver', null = all

  PromoCode({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.usageLimit,
    this.usageCount = 0,
    this.expiryDate,
    this.isActive = true,
    this.userType,
  });

  PromoCode copyWith({
    String? id,
    String? code,
    PromoType? type,
    double? value,
    int? usageLimit,
    int? usageCount,
    DateTime? expiryDate,
    bool? isActive,
    String? userType,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      userType: userType ?? this.userType,
    );
  }

  bool get isExpired =>
      expiryDate != null && DateTime.now().isAfter(expiryDate!);

  bool get canUse =>
      isActive &&
      !isExpired &&
      (usageLimit == null || usageCount < usageLimit!);

  String get formattedValue => type == PromoType.percentage
      ? '${value.toInt()}% OFF'
      : '₱${value.toStringAsFixed(0)} OFF';

  factory PromoCode.fromJson(Map<String, dynamic> json) => PromoCode(
    id: json['id'] as String,
    code: json['code'] as String,
    type: PromoType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PromoType.percentage,
    ),
    value: (json['value'] as num).toDouble(),
    usageLimit: json['usageLimit'] as int?,
    usageCount: json['usageCount'] as int? ?? 0,
    expiryDate: json['expiryDate'] != null
        ? DateTime.parse(json['expiryDate'] as String)
        : null,
    isActive: json['isActive'] as bool? ?? true,
    userType: json['userType'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'type': type.name,
    'value': value,
    'usageLimit': usageLimit,
    'usageCount': usageCount,
    'expiryDate': expiryDate?.toIso8601String(),
    'isActive': isActive,
    'userType': userType,
  };
}
