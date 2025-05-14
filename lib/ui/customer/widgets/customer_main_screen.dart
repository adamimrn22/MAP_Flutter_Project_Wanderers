import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/widgets/profile_screen.dart';
import 'package:mycrochetbag/ui/customer/widgets/customer_bottom_navigation_bar_widget.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  final SignoutViewmodel viewModel = SignoutViewmodel();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      CustomerHomepageScreen(viewModel: viewModel),
      const Scaffold(body: Center(child: Text('Custom Screen'))),
      const Scaffold(body: Center(child: Text('Cart Screen'))),
      const Scaffold(body: Center(child: Text('Orders Screen'))),
      ProfileScreen(viewModel: viewModel), // Pass viewModel to ProfileScreen
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
