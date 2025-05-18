import 'package:flutter/material.dart';
import 'package:mycrochetbag/utils/get_name_initials.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/data/services/auth_service.dart'; // import AuthServices
import 'package:mycrochetbag/ui/core/themes/themes.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Profile'),
        centerTitle: true,
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: FutureBuilder<String?>(
                        future: userNameFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            );
                          } else if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            );
                          } else {
                            final initials = GetNameInitials.getInitials(
                              snapshot.data!,
                            );
                            return Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
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
                  ],
                ),

                const SizedBox(height: 24),

                _buildOptionTile(
                  context,
                  'Language',
                  () {},
                  trailing: const Text('English (UK)'),
                ),

                _buildOptionTile(context, 'Change Password', () {
                  context.push(Routes.changePassword);
                }),
                _buildOptionTile(context, 'Notification Preference', () {
                  // TODO: Implement Notification Preference
                }),
                _buildOptionTile(context, 'Contact Administrator', () {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
                context.push(Routes.login);
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
}
