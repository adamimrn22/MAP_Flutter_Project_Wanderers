import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/view_model/customer_profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/data/services/auth_service.dart'; // import AuthServices
import 'package:mycrochetbag/ui/core/themes/themes.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerProfileViewModel>(
      context,
      listen: false,
    );

    final authService = Provider.of<AuthServices>(
      context,
      listen: false,
    ); // get AuthServices

    // use authService get user email
    final userEmail = authService.currentUserEmail;
    final userNameFuture =
        authService.getCurrentUserName(); // get Future<String?>

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: RoseBlushColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/80',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String?>(
                            // USE FutureBuilder
                            future: userNameFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'error',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                final userName = snapshot.data;
                                return Text(
                                  userName ?? 'please login', // show username
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            },
                          ),
                          Text(
                            userEmail ?? 'please login', //  show email
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Implement edit profile functionality
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),

                _buildOptionTile(
                  context,
                  'Change Password',
                  () => _showChangePasswordDialog(context, viewModel),
                ),
                _buildOptionTile(context, 'Notification Preference', () {
                  // TODO: Implement Notification Preference
                }),
                _buildOptionTile(context, 'Payment Method', () {
                  // TODO: Implement Payment Method
                }),
                _buildOptionTile(context, 'Language', () {
                  // TODO: Implement Language
                }, trailing: const Text('English (UK)')),
                _buildOptionTile(context, 'FAQ', () {
                  // TODO: Implement FAQ
                }),
                _buildOptionTile(context, 'Help Center', () {
                  // TODO: Implement Help Center
                }),
                _buildOptionTile(context, 'Privacy Policy', () {
                  // TODO: Implement Privacy Policy
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            final authService = Provider.of<AuthServices>(
              context,
              listen: false,
            );
            final result = await authService.signOut();
            if (result.isOk) {
              if (context.mounted) {
                context.go(Routes.login);
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sign out fail: ${result.asError.error}'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          child: const Text('Sign out'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    CustomerProfileViewModel viewModel,
  ) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? oldPasswordError;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: oldPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Old Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                      if (oldPasswordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            oldPasswordError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmNewPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value.trim() !=
                              newPasswordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      oldPasswordError = null; // Reset error before submission
                    });

                    if (formKey.currentState!.validate()) {
                      final result = await viewModel.changePassword(
                        oldPassword: oldPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                        confirmNewPassword:
                            confirmNewPasswordController.text.trim(),
                      );

                      if (dialogContext.mounted) {
                        if (result.isOk) {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully'),
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          final error = result.asError.error.toString();
                          print('Error received: $error');

                          if (error.toLowerCase().contains(
                            'auth credential is incorrect',
                          )) {
                            setState(() {
                              oldPasswordError = 'Incorrect old password';
                              oldPasswordController.clear();
                            });
                          } else {
                            Navigator.of(
                              dialogContext,
                            ).pop(); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to change password: $error',
                                ),
                                duration: const Duration(seconds: 3),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
