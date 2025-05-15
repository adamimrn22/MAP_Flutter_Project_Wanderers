import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/utils/result.dart';

class SignoutViewmodel {
  final AuthServices authServices = AuthServices();

  SignoutViewmodel();

  Future<Result<void>> signout() {
    final result = authServices.signOut();
    if (result is Error<void>) {
      print('Login failed! $result');
    }
    return result;
  }
}
