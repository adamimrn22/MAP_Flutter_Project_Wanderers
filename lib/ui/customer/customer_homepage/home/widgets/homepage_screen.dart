import 'package:flutter/material.dart';

class CustomerHomepageScreen extends StatelessWidget {
  const CustomerHomepageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Customer Homepage'),
            ElevatedButton(onPressed: () => (), child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}
