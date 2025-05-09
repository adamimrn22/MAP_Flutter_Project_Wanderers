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
}
