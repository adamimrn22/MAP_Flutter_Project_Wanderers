import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodel.dart';
import 'package:mycrochetbag/ui/seller/seller_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_profile/seller_profile_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_profile/view_model/seller_profile_viewmodel.dart';
import 'package:mycrochetbag/ui/seller/widget/seller_bottom_navigation_bar_widget.dart';

class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;
  final SignoutViewmodel signoutViewModel = SignoutViewmodel();

  @override
  void initState() {
    super.initState();
    _screens = [
      SellerHomepageScreen(viewModel: signoutViewModel), // Home
      const Center(child: Text('Products Page')), // Products
      const Center(child: Text('Order Page')), // Orders
      const SellerProfileScreen(), // Me (Profile)
    ];
  }

  void _onItemTapped(int index) {
    print('Tapped index: $index'); // Debug log
    if (index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerProfileViewModel(),
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: SellerBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
