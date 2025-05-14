import 'package:flutter/foundation.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/utils/result.dart';

class SellerProfileViewModel extends ChangeNotifier {
  final AuthServices authServices = AuthServices();

  Future<Result<void>> signOut() async {
    final Result<void> result = await authServices.signOut();
    if (result.isOk) notifyListeners();
    return result;
  }

  Future<Result<void>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
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

    final result = await authServices.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (result.isOk) notifyListeners();
    return result;
  }
}
