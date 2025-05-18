import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/utils/result.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthServices _authServices;

  LoginViewModel(this._authServices);

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetEmailController = TextEditingController();

  // Form state
  bool isLoading = false;
  bool obscurePassword = true;
  bool showResetForm = false;
  String? errorMessage;
  bool hasError = false;
  String? resetSuccessMessage;

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // Toggle reset form visibility
  void toggleResetForm() {
    showResetForm = !showResetForm;
    errorMessage = null;
    hasError = false;
    resetSuccessMessage = null;
    resetEmailController.clear();
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    errorMessage = null;
    hasError = false;
    resetSuccessMessage = null;
    notifyListeners();
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  String? validateResetEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<Result<void>> login() async {
    setLoading(true);
    errorMessage = null;
    hasError = false;
    resetSuccessMessage = null;

    try {
      final result = await _authServices.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result is Error<void>) {
        print('Login error: ${result.error}');
        errorMessage = _mapFirebaseError(result.error);
        hasError = true;
        notifyListeners();
      }

      return result;
    } catch (e) {
      print('Unexpected error: $e');
      errorMessage = _mapFirebaseError(e);
      hasError = true;
      notifyListeners();
      return Result.error(e as Exception);
    } finally {
      setLoading(false);
    }
  }

  Future<Result<void>> sendPasswordResetEmail() async {
    setLoading(true);
    errorMessage = null;
    hasError = false;
    resetSuccessMessage = null;

    try {
      final result = await _authServices.sendPasswordResetEmail(
        email: resetEmailController.text.trim(),
      );

      if (result.isOk) {
        resetSuccessMessage =
            'Password reset email sent. If you have an account with us, a password reset email has been sent to your inbox';
        showResetForm = false;
        resetEmailController.clear();
      } else {
        errorMessage = _mapFirebaseError(result.asError.error);
        hasError = true;
      }

      notifyListeners();
      return result;
    } catch (e) {
      print('Unexpected error: $e');
      errorMessage = _mapFirebaseError(e);
      hasError = true;
      notifyListeners();
      return Result.error(e as Exception);
    } finally {
      setLoading(false);
    }
  }

  String _mapFirebaseError(dynamic error) {
    print('Raw error: $error');

    // Handle FirebaseAuthException
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
        case 'wrong-password':
        case 'invalid-credential':
        case 'user-not-found':
          return 'Invalid email or password';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'An error occurred: ${error.message ?? error.code}';
      }
    }

    // Fallback for non-Firebase errors
    String errorString = error.toString().toLowerCase();
    return 'An error occurred: ${errorString.length > 50 ? errorString.substring(0, 50) : errorString}';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }
}
