import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/utils/result.dart';
import 'package:flutter/foundation.dart';

class CustomerProfileViewModel extends ChangeNotifier {
  final AuthServices authServices = AuthServices();

  CustomerProfileViewModel();

  Future<Result<void>> signOut() async {
    final Result<void> result = await authServices.signOut();
    if (result.isOk) {
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    // Client-side validation
    if (newPassword != confirmNewPassword) {
      return Result.error(
        Exception('New password and confirm password do not match'),
      );
    }

    if (newPassword.length < 6) {
      return Result.error(
        Exception('New password must be at least 6 characters long'),
      );
    }

    if (newPassword == oldPassword) {
      return Result.error(
        Exception('New password cannot be the same as the old password'),
      );
    }

    // Call the auth service to change the password
    final Result<void> result = await authServices.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    if (result.isOk) {
      notifyListeners();
    }
    return result;
  }
}
