import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/router.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/view_model/customer_profile_viewmodel.dart'; // Make sure you have this file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authServices = AuthServices();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthServices>.value(value: authServices),
        ChangeNotifierProvider<CustomerProfileViewModel>(
          create: (_) => CustomerProfileViewModel(),
        ),
        // You can add more providers here if needed
      ],
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
