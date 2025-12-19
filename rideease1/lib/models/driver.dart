class Driver {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String licensePlate;
  final String vehicleModel;
  final bool isAvailable;
  final String? profileImageUrl;

  Driver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.licensePlate,
    required this.vehicleModel,
    this.isAvailable = true,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'licensePlate': licensePlate,
    'vehicleModel': vehicleModel,
    'isAvailable': isAvailable,
    'profileImageUrl': profileImageUrl,
  };

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    phone: json['phone'],
    licensePlate: json['licensePlate'],
    vehicleModel: json['vehicleModel'],
    isAvailable: json['isAvailable'] ?? true,
    profileImageUrl: json['profileImageUrl'],
  );
}
