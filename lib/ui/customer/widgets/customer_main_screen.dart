import 'package:flutter/material.dart'; //  Provider
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/customer/widgets/customer_bottom_navigation_bar_widget.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/customer_profile_screen.dart'; // Import CustomerProfileScreen
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/view_model/customer_profile_viewmodel.dart'; // 确保导入了 CustomerProfileViewModel

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  _CustomerMainScreenState createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final SignoutViewmodel signoutViewModel =
      SignoutViewmodel(); // Initialize  view model

  @override
  void initState() {
    super.initState();
    _screens = [
      CustomerHomepageScreen(viewModel: signoutViewModel), // Pass the viewModel
      const Center(child: Text('Custom Page')),
      const Center(child: Text('Cart Page')),
      const Center(child: Text('Cart Page')),
      const CustomerProfileScreen(),
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
      bottomNavigationBar: CustomerBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
