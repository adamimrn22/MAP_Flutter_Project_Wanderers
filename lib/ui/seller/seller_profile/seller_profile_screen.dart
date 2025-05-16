import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/seller/seller_profile/view_model/seller_profile_viewmodel.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SellerProfileViewModel>(
      context,
      listen: false,
    );
    final authServices = context.read<AuthServices>();
    final user = authServices.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${user?.email ?? 'Not available'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showChangePasswordDialog(context, viewModel),
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await viewModel.signOut();
                if (context.mounted) {
                  final msg = result.isOk ? 'Signed out' : 'Sign out failed';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: result.isOk ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
