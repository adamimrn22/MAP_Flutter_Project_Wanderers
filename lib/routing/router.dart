import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/repositories/auth/firestore_user_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/seller/seller_profile/seller_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/data/services/manage_user_service.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:mycrochetbag/ui/admin/admin_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/admin/user/view_model/user_viewmodel.dart';
import 'package:mycrochetbag/ui/admin/user/widget/user_detail_screen.dart';
import 'package:mycrochetbag/ui/admin/user/widget/view_all_user_screen.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_main_screen.dart';
import 'package:mycrochetbag/ui/authentication/login/widgets/login_screen.dart';
import 'package:mycrochetbag/ui/authentication/signup/view_model/signup_viewmodel.dart';
import 'package:mycrochetbag/ui/authentication/signup/widgets/signup_screen.dart';
import 'package:mycrochetbag/ui/customer/widgets/customer_main_screen.dart';
import 'package:mycrochetbag/ui/seller/widget/seller_main_screen.dart';
import 'package:mycrochetbag/ui/authentication/forgot_password/widgets/reset_password_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/customer_profile_screen.dart';

GoRouter router(AuthServices authServices) => GoRouter(
  initialLocation: Routes.viewAllUser,
  debugLogDiagnostics: true,
  redirect: buildRedirect(authServices),
  refreshListenable: authServices,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.signUp,
      builder:
          (context, state) =>
              SignUpScreen(viewModel: SignUpViewmodel(context.read())),
    ),
    // GoRoute(
    //   path: Routes.adminHome,
    //   builder: (context, state) => const AdminMainScreen(),
    // ),
    GoRoute(
      path: Routes.customerHome,
      builder: (context, state) => const CustomerMainScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const CustomerProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.sellerHome,
      builder: (context, state) => const SellerMainScreen(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const SellerProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) {
        final oobCode = state.uri.queryParameters['oobCode'] ?? '';
        return ResetPasswordScreen(oobCode: oobCode);
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AdminMainScreen(child: child); // shared layout
      },
      routes: [
        GoRoute(
          path: Routes.adminHome,
          builder: (context, state) => AdminHomepageScreen(),
        ),
        GoRoute(
          path: Routes.viewAllUser,
          builder: (context, state) {
            return ChangeNotifierProvider(
              create:
                  (_) => UserViewModel(
                    userService: ManageUserService(
                      userRepository: FirestoreUserRepository(),
                    ),
                  )..fetchUsers(),
              child: const ViewAllUserScreen(),
            );
          },
        ),
        GoRoute(
          path: Routes.userDetails,
          builder: (context, state) {
            final userId = state.pathParameters['userId'] ?? '';

            // Use the same ViewModel provider from the parent route
            return ChangeNotifierProvider(
              create:
                  (_) => UserViewModel(
                    userService: ManageUserService(
                      userRepository: FirestoreUserRepository(),
                    ),
                  )..fetchUserById(userId),
              child: UserDetailsScreen(userId: userId),
            );
          },
        ),
      ],
    ),
    // GoRoute(
    //   path: Routes.viewAllUser,
    //   builder: (context, state) {
    //     return ChangeNotifierProvider(
    //       create:
    //           (_) => UserViewModel(
    //             userService: ManageUserService(
    //               userRepository: FirestoreUserRepository(),
    //             ),
    //           )..fetchUsers(),
    //       child: const ViewAllUserScreen(),
    //     );
    //   },
    // ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Error: Route not found - ${state.uri}')),
      ),
);

buildRedirect(AuthServices authServices) {
  return (BuildContext context, GoRouterState state) async {
    final isAuthPage =
        state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.signUp;
    final isLoggedIn = authServices.currentUser != null;

    if (!isLoggedIn && !isAuthPage) return Routes.login;

    if (isLoggedIn) {
      try {
        final role = await authServices.getUserRole();
        if (role == null) {
          await authServices.signOut();
          return Routes.login;
        }

        final homeRoute = _getHomeRouteForRole(role);
        if (isAuthPage) return homeRoute;

        final isAccessingAdminRoute = state.matchedLocation.startsWith(
          '/admin',
        );
        final isAccessingCustomerRoute = state.matchedLocation.startsWith(
          '/customer',
        );
        final isAccessingSellerRoute = state.matchedLocation.startsWith(
          '/seller',
        );

        final isAccessingWrongRoute =
            (isAccessingAdminRoute && role != 'admin') ||
            (isAccessingCustomerRoute && role != 'customer') ||
            (isAccessingSellerRoute && role != 'seller');

        if (isAccessingWrongRoute) return homeRoute;
      } catch (e) {
        print('Error during route redirection: $e');
        await authServices.signOut();
        return Routes.login;
      }
    }

    return null;
  };
}

String _getHomeRouteForRole(String role) {
  switch (role) {
    case 'admin':
      return Routes.adminHome;
    case 'customer':
      return Routes.customerHome;
    case 'seller':
      return Routes.sellerHome;
    default:
      return Routes.login;
  }
}
