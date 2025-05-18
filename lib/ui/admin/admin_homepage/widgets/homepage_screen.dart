import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';

class AdminHomepageScreen extends StatefulWidget {
  const AdminHomepageScreen({super.key});
  @override
  State<AdminHomepageScreen> createState() => _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends State<AdminHomepageScreen> {
  final SignoutViewmodel viewModel = SignoutViewmodel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const Text('Admin Dashboard')],
        ),
      ),
    );
  }
}
