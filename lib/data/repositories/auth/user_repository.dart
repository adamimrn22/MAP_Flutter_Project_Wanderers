import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/utils/result.dart';

abstract class UserRepository {
  Future<Result<List<User>>> getUsers();
  Future<Result<User>> getUserById(String id);
  Future<Result<User>> createUser(User user);
  Future<Result<User>> updateUser(User user);
  Future<Result<bool>> deleteUser(String id);
}
