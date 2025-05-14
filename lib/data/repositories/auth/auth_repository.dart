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
  Future<Result<void>> sendPasswordResetEmail({required String email});
  Future<Result<String>> verifyPasswordResetCode({required String oobCode});
  Future<Result<void>> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  });
  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
