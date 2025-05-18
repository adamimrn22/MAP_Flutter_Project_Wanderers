import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';

class AdminHomepageScreen extends StatefulWidget {
  final SignoutViewmodel viewModel;

  const AdminHomepageScreen({super.key, required this.viewModel});
  @override
  State<AdminHomepageScreen> createState() => _AdminHomepageScreenState();
}

class _AdminHomepageScreenState extends State<AdminHomepageScreen> {
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
