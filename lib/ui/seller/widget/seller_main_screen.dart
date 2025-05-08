import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';
import 'package:mycrochetbag/ui/seller/seller_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/seller/widget/seller_bottom_navigation_bar_widget.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _selectedIndex = 0;

  final SignoutViewmodel viewModel = SignoutViewmodel();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // ADD SCREEN HEREEEE
    _screens = [SellerHomepageScreen(viewModel: viewModel)];
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
      bottomNavigationBar: SellerBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
