import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final SignoutViewmodel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;

  Future<void> _sendPasswordResetEmail(String email) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = context.read<AuthServices>();
      final result = await authService.sendPasswordResetEmail(
        email: email.trim(),
      );

      if (result.isOk) {
        setState(() {
          _successMessage = 'Password reset email sent. Check your inbox.';
        });
      } else {
        setState(() {
          _errorMessage = _parseErrorMessage(result.asError.error.toString());
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email format.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();
    // Pre-fill email if available
    final authService = context.read<AuthServices>();
    final currentUser = authService.currentUser;
    if (currentUser != null && currentUser.email != null) {
      emailController.text = currentUser.email!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendPasswordResetEmail(emailController.text);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    ).whenComplete(() {
      emailController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthServices>();
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome, ${currentUser?.email ?? 'Guest'}!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _showResetPasswordDialog,
                      child: const Text('Reset Password'),
                    ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final result = await widget.viewModel.signout();
                    if (result.isOk && context.mounted) {
                      context.go(Routes.login);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Sign out failed: ${result.asError.error}',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Sign Out'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
