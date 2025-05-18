import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_bottom_navigation_bar_widget.dart';
import 'package:provider/provider.dart';

class AdminMainScreen extends StatelessWidget {
  final Widget child;
  const AdminMainScreen({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminNavigationProvider(),
      child: Consumer<AdminNavigationProvider>(
        builder: (context, navProvider, _) {
          // Update selected index based on current route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final location = GoRouterState.of(context).uri.toString();
            navProvider.updateIndexFromRoute(location);
          });

          return Scaffold(
            body: child,
            bottomNavigationBar: AdminBottomNavBar(
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

class AdminNavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  static const _routeIndices = {
    Routes.adminHome: 0,
    Routes.viewAllUser: 1,
    Routes.adminProfile: 2,
  };

  static const _indexRoutes = [
    Routes.adminHome,
    Routes.viewAllUser,
    Routes.adminProfile,
  ];

  void updateIndexFromRoute(String location) {
    _selectedIndex =
        _routeIndices.entries
            .firstWhere(
              (entry) => location.startsWith(entry.key),
              orElse: () => const MapEntry(Routes.adminHome, 0),
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
