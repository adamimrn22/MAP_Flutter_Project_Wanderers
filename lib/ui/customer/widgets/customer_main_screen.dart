import 'package:flutter/material.dart'; //  Provider
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/customer/widgets/customer_bottom_navigation_bar_widget.dart';
import 'package:provider/provider.dart';

class CustomerMainScreen extends StatelessWidget {
  final Widget child;
  const CustomerMainScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerNavigationProvider(),
      child: Consumer<CustomerNavigationProvider>(
        builder: (context, navProvider, _) {
          // Update selected index based on current route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final location = GoRouterState.of(context).uri.toString();
            navProvider.updateIndexFromRoute(location);
          });

          return Scaffold(
            body: child,
            bottomNavigationBar: CustomerBottomNavBar(
              currentIndex: navProvider.selectedIndex,
              onTap: (index) {
                navProvider.setIndex(index);
                context.push(navProvider.getRouteForIndex(index));
              },
            ),
          );
        },
      ),
    );
  }
}

class CustomerNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  static const _routeIndices = {
    Routes.customerHome: 0,
    Routes.customerCustomOrder: 1,
    Routes.customerCart: 2,
    Routes.customerOrders: 3,
    Routes.customerProfile: 4,
  };

  static const _indexRoutes = [
    Routes.customerHome,
    Routes.customerCustomOrder,
    Routes.customerCart,
    Routes.customerOrders,
    Routes.customerProfile,
  ];

  void updateIndexFromRoute(String location) {
    _selectedIndex =
        _routeIndices.entries
            .firstWhere(
              (entry) => location.startsWith(entry.key),
              orElse: () => const MapEntry(Routes.customerHome, 0),
            )
            .value;
    notifyListeners();
  }

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  String getRouteForIndex(int index) => _indexRoutes[index];
}
