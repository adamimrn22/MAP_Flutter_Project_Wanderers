import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_main_screen.dart';
import 'package:mycrochetbag/ui/authentication/login/widgets/login_screen.dart';
import 'package:mycrochetbag/ui/authentication/signup/view_model/signup_viewmodel.dart';
import 'package:mycrochetbag/ui/authentication/signup/widgets/signup_screen.dart';
import 'package:mycrochetbag/ui/customer/widgets/customer_main_screen.dart';
import 'package:mycrochetbag/ui/seller/widget/seller_main_screen.dart';
import 'package:mycrochetbag/ui/authentication/forgot_password/widgets/reset_password_screen.dart';
import 'package:provider/provider.dart';

// Main router setup
GoRouter router(AuthServices authServices) => GoRouter(
  initialLocation: Routes.login,
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
    GoRoute(
      path: Routes.adminHome,
      builder: (context, state) => const AdminMainScreen(),
    ),
    GoRoute(
      path: Routes.customerHome,
      builder: (context, state) => const CustomerMainScreen(),
    ),
    GoRoute(
      path: Routes.sellerHome,
      builder: (context, state) => const SellerMainScreen(),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) {
        final oobCode = state.uri.queryParameters['oobCode'] ?? '';
        return ResetPasswordScreen(oobCode: oobCode);
      },
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Error: Route not found - ${state.uri}')),
      ),
);

buildRedirect(AuthServices authServices) {
  return (BuildContext context, GoRouterState state) async {
    // Check if user is on login or singup screen
    final isAuthPage =
        state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.signUp;

    // Check if user is logged in
    final isLoggedIn = authServices.currentUser != null;

    // Not logged in and not on auth page -> redirect to login
    if (!isLoggedIn && !isAuthPage) {
      return Routes.login;
    }

    // Logged in -> verify role and handle rbac
    if (isLoggedIn) {
      try {
        final role = await authServices.getUserRole();

        // If role is missing, sign out and redirect to login
        if (role == null) {
          await authServices.signOut();
          return Routes.login;
        }

        // Get the home route for current user role
        final homeRoute = _getHomeRouteForRole(role);

        // If on auth route (login, signup), redirect to user role home route
        if (isAuthPage) {
          return homeRoute;
        }

        // Check if user is trying to access a route not meant for their role
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

        // If accessing wrong route, redirect to appropriate home
        if (isAccessingWrongRoute) {
          return homeRoute;
        }
      } catch (e) {
        // Log error
        print('Error during route redirection: $e');
        await authServices.signOut();
        return Routes.login;
      }
    }

    // Allow the navigation to proceed (return null)
    return null;
  };
}

// check user role
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
