import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(TablerIcons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(TablerIcons.users), label: 'Users'),
        BottomNavigationBarItem(
          icon: Icon(TablerIcons.user_circle),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.black54,
      onTap: onTap,
    );
  }
}
