import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/homepage_screen.dart';
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
    // ADD SCREEN HEREEEE
    _screens = [CustomerHomepageScreen(viewModel: viewModel)];
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
