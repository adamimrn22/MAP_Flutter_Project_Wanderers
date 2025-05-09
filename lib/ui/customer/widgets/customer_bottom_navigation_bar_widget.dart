import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';

class CustomerBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomerBottomNavBarState createState() => _CustomerBottomNavBarState();
}

class _CustomerBottomNavBarState extends State<CustomerBottomNavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(TablerIcons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(TablerIcons.briefcase),
          label: 'Custom',
        ),
        BottomNavigationBarItem(
          icon: Icon(TablerIcons.shopping_bag),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(TablerIcons.clipboard),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(TablerIcons.user_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTap(index);
        if (index == 4) {
          context.go('${Routes.customerHome}/profile');
        } else if (index == 0) {
          context.go(Routes.customerHome);
        }
        //  else if (index == 1) {
        //   context.go('/custom');
        // }
      },
    );
  }
}
