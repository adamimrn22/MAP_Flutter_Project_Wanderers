import 'package:flutter/material.dart';

class SellerHomepageScreen extends StatefulWidget {
  const SellerHomepageScreen({super.key});

  @override
  State<SellerHomepageScreen> createState() => _SellerHomepageScreenState();
}

class _SellerHomepageScreenState extends State<SellerHomepageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text('Seller Dashboard')],
        ),
      ),
    );
  }
}
