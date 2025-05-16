import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';

class CustomerHomepageScreen extends StatefulWidget {
  final SignoutViewmodel viewModel;
  const CustomerHomepageScreen({super.key, required this.viewModel});

  @override
  State<CustomerHomepageScreen> createState() => _CustomerHomepageScreenState();
}

class _CustomerHomepageScreenState extends State<CustomerHomepageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}
