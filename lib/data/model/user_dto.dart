import 'package:mycrochetbag/domain/model/User.dart';

class UserDto {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;

  UserDto({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  // Convert UserDto object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  // Create UserDto object from Firestore document
  factory UserDto.fromMap(Map<String, dynamic> map, String docId) {
    return UserDto(
      id: docId,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
    );
  }

  // Convert Domain User to UserDto
  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      role: user.role,
    );
  }

  // Convert UserDto to Domain User
  User toDomain() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
    );
  }
}

extension UserDtoExtension on UserDto {
  UserDto copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? role,
  }) {
    return UserDto(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}
