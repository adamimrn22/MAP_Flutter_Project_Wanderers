import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/utils/result.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthServices authServices = AuthServices();

  // Controllers for password fields
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();

  // Visibility toggles
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  bool obscureOldPassword = true;

  // Toggle methods
  void toggleNewPasswordVisibility() {
    obscureNewPassword = !obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void toggleOldPasswordVisibility() {
    obscureOldPassword = !obscureOldPassword;
    notifyListeners();
  }

  // Validation methods
  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a new password';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your new password';
    }
    if (value.trim() != newPasswordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

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
      signOut();
    }
    return result;
  }
}
