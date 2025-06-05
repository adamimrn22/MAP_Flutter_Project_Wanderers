import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:mycrochetbag/ui/customer/customer_view_bag/view_model/cart_viewmodel.dart';
import 'package:provider/provider.dart';

class CustomerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(TablerIcons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(TablerIcons.briefcase),
          label: 'Custom',
        ),
        BottomNavigationBarItem(
          icon: Builder(
            builder: (context) {
              try {
                return Consumer<CartViewModel>(
                  builder: (context, cartViewModel, child) {
                    return BadgedIcon(
                      icon: TablerIcons.shopping_bag,
                      badgeColor: Theme.of(context).primaryColor,
                      badgeCount:
                          cartViewModel.totalQuantity > 0
                              ? cartViewModel.totalQuantity
                              : null,
                    );
                  },
                );
              } catch (e) {
                return BadgedIcon(
                  icon: TablerIcons.shopping_bag,
                  badgeColor: Theme.of(context).primaryColor,
                  badgeCount: null,
                );
              }
            },
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(TablerIcons.clipboard),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
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

class BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int? badgeCount;
  final Color? badgeColor;
  final Color textColor;
  final double badgeSize;

  const BadgedIcon({
    super.key,
    required this.icon,
    this.badgeCount,
    this.badgeColor,
    this.textColor = Colors.white,
    this.badgeSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBadgeColor =
        badgeColor ?? Theme.of(context).primaryColor;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badgeCount != null && badgeCount! > 0)
          Positioned(
            right: -16,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: resolvedBadgeColor,
                borderRadius: BorderRadius.circular(badgeSize / 2),
              ),
              constraints: BoxConstraints(
                minWidth: badgeSize,
                minHeight: badgeSize,
              ),
              child: Text(
                badgeCount! > 99 ? '99+' : badgeCount.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
