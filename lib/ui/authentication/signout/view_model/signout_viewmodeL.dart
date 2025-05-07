import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/utils/result.dart';

class SignoutViewmodel {
  final AuthServices _authServices;

  SignoutViewmodel(this._authServices);

  Future<Result<void>> signout() {
    final result = _authServices.signOut();
    if (result is Error<void>) {
      print('Login failed! $result');
    }
    return result;
  }
}
