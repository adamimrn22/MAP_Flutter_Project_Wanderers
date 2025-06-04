import 'package:flutter/material.dart';
import 'package:mycrochetbag/utils/get_name_initials.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/ui/core/themes/themes.dart';
import 'package:mycrochetbag/firebase_services.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      setState(() {
        _userData = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final data = await _firestoreService.getUserData(userId);
      setState(() {
        _userData = data;
        _loading = false;
      });
    } catch (e) {
      print("❌ Error fetching user data: $e");
      setState(() {
        _userData = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context, listen: false);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userEmail = authService.currentUserEmail ?? 'please login';
    final userName =
        _userData != null
            ? '${_userData!['firstName'] ?? ''} ${_userData!['lastName'] ?? ''}'
                .trim()
            : 'please login';
    final profilePictureUrl = _userData?['profilePictureUrl'] ?? '';

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
                      child:
                          profilePictureUrl.isNotEmpty
                              ? ClipOval(
                                child: Image.network(
                                  '$profilePictureUrl?${DateTime.now().millisecondsSinceEpoch}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Text(
                                        GetNameInitials.getInitials(userName),
                                        style: const TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                        ),
                                      ),
                                ),
                              )
                              : Text(
                                GetNameInitials.getInitials(userName),
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isEmpty ? 'please login' : userName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            userEmail,
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
                _buildOptionTile(context, 'Edit Profile', () {
                  context.push(Routes.customerEditProfile).then((_) {
                    // Refresh user data after editing
                    _fetchUserData();
                  });
                }),
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
                _buildOptionTile(context, 'Payment Method', () {
                  // TODO: Implement Payment Method
                }),
                _buildOptionTile(context, 'FAQ', () {
                  // TODO: Implement FAQ
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
