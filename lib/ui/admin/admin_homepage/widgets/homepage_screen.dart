import 'package:flutter/material.dart';

class AdminHomepageScreen extends StatelessWidget {
  const AdminHomepageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Admin Dashboard'),
            ElevatedButton(onPressed: () => (), child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}
