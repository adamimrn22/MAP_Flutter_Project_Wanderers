import 'package:mycrochetbag/utils/result.dart';

abstract class AuthRepository {
  Stream<bool> get isAuthenticatedStream;
  Future<Result<void>> login({required String email, required String password});

  Future<Result<void>> customerSignUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });
}
