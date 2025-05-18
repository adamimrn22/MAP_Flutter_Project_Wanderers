import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/router.dart';
import 'package:mycrochetbag/ui/authentication/change_password/view_model/change_password_view_model.dart'; // Import CustomerProfileViewModel

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8E4A58), // Ba  For iOS
    ),
  );
  final authServices = AuthServices();

  runApp(
    MultiProvider(
      // Use MultiProvider
      providers: [
        ChangeNotifierProvider<AuthServices>.value(
          // Changed to ChangeNotifierProvider
          value: authServices,
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
