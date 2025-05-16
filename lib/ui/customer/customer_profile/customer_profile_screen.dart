import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/data/services/auth_services.dart'; // import AuthServices
import 'package:mycrochetbag/ui/core/themes/themes.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({Key? key}) : super(key: key);

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

                _buildOptionTile(context, 'Privacy & Security', () {
                  // TODO: Implement Privacy & Security
                }),
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
}
