import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/data/model/user_dto.dart';
import 'package:mycrochetbag/data/repositories/auth/user_repository.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/utils/result.dart';

class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'users';

  FirestoreUserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(_collectionName);

  @override
  Future<Result<List<User>>> getUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      final userDtos =
          snapshot.docs
              .map((doc) => UserDto.fromMap(doc.data(), doc.id))
              .toList();

      final users = userDtos.map((dto) => dto.toDomain()).toList();
      return Result.ok(users);
    } catch (e) {
      return Result.error(Exception('Failed to fetch users: $e'));
    }
  }

  @override
  Future<Result<User>> getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (!doc.exists) {
        return Result.error(Exception('User not found'));
      }

      final userDto = UserDto.fromMap(doc.data()!, doc.id);
      return Result.ok(userDto.toDomain());
    } catch (e) {
      return Result.error(Exception('Failed to fetch user: $e'));
    }
  }

  @override
  Future<Result<User>> createUser(User user) async {
    try {
      final userDto = UserDto.fromDomain(user);
      final docRef = await _usersCollection.add(userDto.toMap());

      final newUserDto = userDto.copyWith(id: docRef.id);
      return Result.ok(newUserDto.toDomain());
    } catch (e) {
      return Result.error(Exception('Failed to create user: $e'));
    }
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    try {
      if (user.id == null) {
        return Result.error(
          Exception('User ID cannot be null for update operation'),
        );
      }

      final userDto = UserDto.fromDomain(user);
      await _usersCollection.doc(user.id).update(userDto.toMap());

      return Result.ok(user);
    } catch (e) {
      return Result.error(Exception('Failed to update user: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteUser(String id) async {
    try {
      await _usersCollection.doc(id).delete();
      return Result.ok(true);
    } catch (e) {
      return Result.error(Exception('Failed to delete user: $e'));
    }
  }
}
