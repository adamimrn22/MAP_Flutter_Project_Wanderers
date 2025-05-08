import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';

class SellerHomepageScreen extends StatefulWidget {
  final SignoutViewmodel viewModel;
  const SellerHomepageScreen({super.key, required this.viewModel});

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
          children: [
            const Text('Seller Dashboard'),
            ElevatedButton(
              onPressed: () => widget.viewModel.signout(),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
