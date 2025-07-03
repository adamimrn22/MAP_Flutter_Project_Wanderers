class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  factory User.fromMap(Map<String, dynamic> map, {String? id}) {
    return User(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $firstName $lastName, email: $email, phone: $phoneNumber, role: $role)';
  }
}
