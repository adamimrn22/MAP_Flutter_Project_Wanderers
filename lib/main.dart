import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/routing/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authServices = AuthServices();

  runApp(
    ChangeNotifierProvider<AuthServices>.value(
      value: authServices,
      child: MainApp(authServices: authServices),
    ),
  );
}

class MainApp extends StatelessWidget {
  final AuthServices authServices;

  const MainApp({Key? key, required this.authServices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My Crochet Bag',
      theme: roseBlushTheme,
      routerConfig: router(authServices),
    );
  }
}
