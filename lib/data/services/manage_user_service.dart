import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/data/repositories/auth/user_repository.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/utils/result.dart';

class ManageUserService {
  final UserRepository _userRepository;

  ManageUserService({required UserRepository userRepository})
    : _userRepository = userRepository;

  Future<Result<List<User>>> getAllUsers() async {
    return await _userRepository.getUsers();
  }

  Future<Result<User>> getUserDetails(String id) async {
    return await _userRepository.getUserById(id);
  }

  Future<Result<User>> addUser(User user) async {
    return await _userRepository.createUser(user);
  }

  Future<Result<User>> editUser(User user) async {
    return await _userRepository.updateUser(user);
  }

  Future<Result<bool>> removeUser(String id) async {
    return await _userRepository.deleteUser(id);
  }

  static Future<User?> fetchUserById(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!, id: doc.id);
      }

      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }
}
