import 'package:flutter/material.dart';

class SellerHomepageScreen extends StatelessWidget {
  const SellerHomepageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Seller Dashboard'),
            ElevatedButton(onPressed: () => (), child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}
