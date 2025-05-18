import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_bottom_navigation_bar_widget.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';
import 'package:mycrochetbag/ui/admin/admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final Widget child;
  const AdminMainScreen({required this.child, super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();

    // Automatically update nav index based on route
    if (location.startsWith(Routes.adminHome)) {
      _selectedIndex = 0;
    } else if (location.startsWith(Routes.viewAllUser)) {
      _selectedIndex = 1;
    } else {
      _selectedIndex = 0; // fallback
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.push(Routes.adminHome);
        break;
      case 1:
        context.push(Routes.viewAllUser);
        break;
      case 2:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile")));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AdminBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
