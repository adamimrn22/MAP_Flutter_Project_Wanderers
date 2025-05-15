import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/utils/result.dart';

class SignUpViewmodel extends ChangeNotifier {
  final AuthServices _authServices;

  SignUpViewmodel(this._authServices);

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form state
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? errorMessage;
  bool hasError = false;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (RegExp(r'[0-9]').hasMatch(value)) return 'Name cannot contain numbers';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{3}-\d{4,}$').hasMatch(value)) {
      return 'Invalid format (e.g. 010-1234567)';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<Result<void>> signUp() async {
    setLoading(true);
    errorMessage = null;
    hasError = false;

    try {
      final result = await _authServices.customerSignUp(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      if (result is Error<void>) {
        final error = result.error.toString();

        if (error.contains('email-already-in-use')) {
          errorMessage =
              'This email is already registered. Please use a different email or sign in.';
        } else if (error.contains('weak-password')) {
          errorMessage =
              'Password is too weak. Please use a stronger password with more than 6 digits';
        } else if (error.contains('invalid-email')) {
          errorMessage = 'Invalid email format.';
        } else {
          errorMessage = 'Sign up failed. Please try again.';
        }

        hasError = true;
        notifyListeners();
      }

      return result;
    } finally {
      setLoading(false);
    }
  }

  void clearError() {
    errorMessage = null;
    hasError = false;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
