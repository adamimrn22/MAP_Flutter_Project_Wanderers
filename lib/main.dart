import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mycrochetbag/ui/admin/admin_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/authentication/login/widgets/login_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_homepage/widgets/homepage_screen.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const LoginScreen();
          }
          final user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // If there was an error or no data was found
              if (roleSnapshot.hasError ||
                  !roleSnapshot.hasData ||
                  !roleSnapshot.data!.exists) {
                print("Error fetching user role: ${roleSnapshot.error}");
                return const Center(
                  child: Text('Error: Could not fetch user role'),
                );
              }

              // Successfully fetched user data
              final role = roleSnapshot.data!.get('role') as String?;
              if (role == null) {
                return const Center(child: Text('Error: Role not found'));
              }

              // Navigate based on role
              switch (role) {
                case 'admin':
                  return const AdminHomepageScreen();
                case 'customer':
                  return const CustomerHomepageScreen();
                case 'seller':
                  return const SellerHomepageScreen();
                default:
                  return const Center(child: Text('Error: Invalid role'));
              }
            },
          );
        },
      ),
    );
  }
}
