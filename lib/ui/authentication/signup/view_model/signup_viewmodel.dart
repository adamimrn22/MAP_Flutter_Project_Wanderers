import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/utils/result.dart';

class SignUpViewmodel extends ChangeNotifier {
  final AuthServices _authServices;

  SignUpViewmodel(this._authServices);

  Future<Result<void>> signUp(
    (String, String, String, String, String) credentials,
  ) async {
    final (firstName, lastName, email, phoneNumber, password) = credentials;
    final result = await _authServices.customerSignUp(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );
    if (result is Error<void>) {
      print('Login failed! ${result.error}');
      return result;
    }
    return result;
  }
}
