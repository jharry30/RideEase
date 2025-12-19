class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isDriver;
  final bool isAdmin;
  final String? profileImageUrl;
  final String? vehicleModel;
  final String? licensePlate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.isDriver = false,
    this.isAdmin = false,
    this.profileImageUrl,
    this.vehicleModel,
    this.licensePlate,
  });

  // Getter for full name
  String get name => '$firstName $lastName';

  // Getter for userType (for compatibility)
  String get userType => isDriver ? 'driver' : 'rider';

  // Copy with method
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? isDriver,
    bool? isAdmin,
    String? profileImageUrl,
    String? vehicleModel,
    String? licensePlate,
    required String name,
    required photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isDriver: isDriver ?? this.isDriver,
      isAdmin: isAdmin ?? this.isAdmin,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      licensePlate: licensePlate ?? this.licensePlate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'isDriver': isDriver,
        'isAdmin': isAdmin,
        'profileImageUrl': profileImageUrl,
        'vehicleModel': vehicleModel,
        'licensePlate': licensePlate,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? '',
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        isDriver: json['isDriver'] ?? false,
        isAdmin: json['isAdmin'] ?? false,
        profileImageUrl: json['profileImageUrl'],
        vehicleModel: json['vehicleModel'],
        licensePlate: json['licensePlate'],
      );

  // Factory constructor for creating from Firebase Auth user
  factory User.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    bool emailVerified = false,
  }) {
    String firstName = '';
    String lastName = '';

    if (displayName != null && displayName.contains(' ')) {
      final parts = displayName.split(' ');
      firstName = parts.first;
      lastName = parts.sublist(1).join(' ');
    } else if (displayName != null) {
      firstName = displayName;
    } else {
      firstName = email.split('@').first;
    }

    return User(
      id: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phoneNumber ?? '',
      isDriver: false,
      isAdmin: false,
      profileImageUrl: photoURL,
    );
  }

  static User empty() {
    return User(id: '', firstName: '', lastName: '', email: '', phone: '');
  }

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  Null get photoUrl => null;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isDriver: $isDriver)';
  }
}
