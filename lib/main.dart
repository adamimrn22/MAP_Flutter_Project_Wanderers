import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/routing/router.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/view_model/customer_profile_viewmodel.dart'; // Import CustomerProfileViewModel

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authServices = AuthServices();

  runApp(
    MultiProvider(
      // Use MultiProvider
      providers: [
        ChangeNotifierProvider<AuthServices>.value(
          // Changed to ChangeNotifierProvider
          value: authServices,
        ),
        ChangeNotifierProvider<CustomerProfileViewModel>(
          // Add this Provider
          create: (_) => CustomerProfileViewModel(),
        ),
        // Add other Providers as needed
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
