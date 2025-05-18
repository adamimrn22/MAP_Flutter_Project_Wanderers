import 'package:flutter/material.dart'; //  Provider
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/seller/widget/seller_bottom_navigation_bar_widget.dart';
import 'package:provider/provider.dart';

class SellerMainScreen extends StatelessWidget {
  final Widget child;
  const SellerMainScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellerNavigationProvider(),
      child: Consumer<SellerNavigationProvider>(
        builder: (context, navProvider, _) {
          // Update selected index based on current route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final location = GoRouterState.of(context).uri.toString();
            navProvider.updateIndexFromRoute(location);
          });

          return Scaffold(
            body: child,
            bottomNavigationBar: SellerBottomNavBar(
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

class SellerNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  static const _routeIndices = {
    Routes.sellerHome: 0,
    Routes.sellerProduct: 1,
    Routes.sellerOrders: 2,
    Routes.sellerProfile: 3,
  };

  static const _indexRoutes = [
    Routes.sellerHome,
    Routes.sellerProduct,
    Routes.sellerOrders,
    Routes.sellerProfile,
  ];

  void updateIndexFromRoute(String location) {
    _selectedIndex =
        _routeIndices.entries
            .firstWhere(
              (entry) => location.startsWith(entry.key),
              orElse: () => const MapEntry(Routes.sellerHome, 0),
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
