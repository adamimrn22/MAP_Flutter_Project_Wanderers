class User {
  final String uid;
  final String email;
  final String role;

  User({required this.uid, required this.email, required this.role});

  factory User.fromFirestore(Map<String, dynamic> data, String uid) {
    return User(uid: uid, email: data['email'] ?? '', role: data['role'] ?? '');
  }
}
