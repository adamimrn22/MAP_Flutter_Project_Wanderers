import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/admin/admin_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_bottom_navigation_bar_widget.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';
import 'package:mycrochetbag/ui/admin/admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final SignoutViewmodel viewModel = SignoutViewmodel();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // ADD SCREEN HEREEEE
    _screens = [
      AdminHomepageScreen(viewModel: viewModel),
      const Center(child: Text('Admin Users Management Page')),
      const AdminProfileScreen(), // <--  AdminProfileScreen
    ];
  }

  void _onItemTapped(int index) {
    if (index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
