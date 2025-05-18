import 'package:flutter/material.dart';

class CustomerHomepageScreen extends StatefulWidget {
  const CustomerHomepageScreen({super.key});

  @override
  State<CustomerHomepageScreen> createState() => _CustomerHomepageScreenState();
}

class _CustomerHomepageScreenState extends State<CustomerHomepageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Customer Homepage")));
  }
}
