import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mycrochetbag/data/services/cart_service.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:mycrochetbag/ui/customer/customer_view_bag/view_model/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/router.dart'; // Import CustomerProfileViewModel
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://tqcopbevuoywwkqjfjqv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxY29wYmV2dW95d3drcWpmanF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5MjE0NDAsImV4cCI6MjA2MzQ5NzQ0MH0.puuOXDQMDY77ijazssFR2Zm-dk1ZScQbgNNbibHwySM',
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8E4A58), // Ba  For iOS
    ),
  );

  final authServices = AuthServices();
  final cartService = FirestoreCartService();

  runApp(
    MultiProvider(
      // Use MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => AuthServices()),
        ChangeNotifierProxyProvider<AuthServices, CartViewModel?>(
          create: (_) => null,
          update: (context, authService, previous) {
            if (authService.currentUser != null) {
              return CartViewModel(cartService, authService.currentUser!.uid);
            }
            previous?.dispose();
            return null;
          },
        ),
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
      routerConfig: router(authServices),
      title: 'My Crochet Bag',
      theme: roseBlushTheme,
    );
  }
}
