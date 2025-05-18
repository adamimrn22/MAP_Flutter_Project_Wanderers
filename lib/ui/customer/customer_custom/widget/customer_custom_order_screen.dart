import 'package:flutter/material.dart';

class CustomerCustomOrderScreen extends StatefulWidget {
  const CustomerCustomOrderScreen({super.key});

  @override
  State<CustomerCustomOrderScreen> createState() =>
      _CustomerCustomOrderScreenState();
}

class _CustomerCustomOrderScreenState extends State<CustomerCustomOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Customer Custom Order")));
  }
}
