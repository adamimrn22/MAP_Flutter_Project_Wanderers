import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/services/auth_services.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/admin/admin_homepage/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/authentication/login/widgets/login_screen.dart';
import 'package:mycrochetbag/ui/authentication/signout/view_model/signout_viewmodeL.dart';
import 'package:mycrochetbag/ui/authentication/signup/view_model/signup_viewmodel.dart';
import 'package:mycrochetbag/ui/authentication/signup/widgets/signup_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/homepage_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_homepage/widgets/homepage_screen.dart';
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
      builder: (context, state) => const AdminHomepageScreen(),
    ),
    GoRoute(
      path: Routes.customerHome,
      builder:
          (context, state) => CustomerHomepageScreen(
            viewModel: SignoutViewmodel(context.read()),
          ),
    ),
    GoRoute(
      path: Routes.sellerHome,
      builder: (context, state) => const SellerHomepageScreen(),
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Error: Route not found - ${state.uri}')),
      ),
);

buildRedirect(AuthServices authServices) {
  return (BuildContext context, GoRouterState state) async {
    // Check authentication status
    final loggedIn = authServices.currentUser != null;
    // Check if user is on login or signup page
    final isLoggingIn =
        state.matchedLocation == Routes.login ||
        state.matchedLocation == Routes.signUp;

    // If not logged in and not on login/signup page, redirect to login
    if (!loggedIn && !isLoggingIn) {
      print('true');
      return Routes.login;
    }

    // If logged in, fetch user role and redirect accordingly
    if (loggedIn) {
      print('test');
      try {
        final role = await authServices.getUserRole();
        if (role == null) {
          // If role is missing, redirect to login and optionally sign out
          await authServices.signOut();
          return Routes.login;
        }

        // If user is on login/signup page, redirect based on role
        if (isLoggingIn) {
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

        // Restrict access to role-specific routes
        final goingToAdminRoute = state.matchedLocation == Routes.adminHome;
        final goingToCustomerRoute =
            state.matchedLocation == Routes.customerHome;
        final goingToSellerRoute = state.matchedLocation == Routes.sellerHome;

        if ((goingToAdminRoute && role != 'admin') ||
            (goingToCustomerRoute && role != 'customer') ||
            (goingToSellerRoute && role != 'seller')) {
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
      } catch (e) {
        print('Error in redirect: $e');
        // On error, redirect to login
        await authServices.signOut();
        return Routes.login;
      }
    }

    print('test');
  };
}

// Future<String?> Function(BuildContext, GoRouterState) buildRedirect(
//   AuthServices authServices,
// ) {
//   return (BuildContext context, GoRouterState state) async {
//     // Check if the user is authenticated
//     final loggedIn = await _getAuthenticationStatus(context);

//     // Check if user is on login or signup page
//     final isLoggingIn =
//         state.matchedLocation == Routes.login ||
//         state.matchedLocation == Routes.signUp;

//     // If not logged in and not on login/signup page, redirect to login
//     if (!loggedIn && !isLoggingIn) {
//       return Routes.login;
//     }

//     // If logged in, check the role and redirect based on role
//     if (loggedIn) {
//       // get the user role
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         try {
//           final userDoc =
//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(user.uid)
//                   .get();

//           if (userDoc.exists) {
//             final role = userDoc.get('role') as String?;

//             // If user is on login page but already logged in, redirect based on role
//             if (isLoggingIn) {
//               switch (role) {
//                 case 'admin':
//                   return Routes.adminHome;
//                 case 'customer':
//                   return Routes.customerHome;
//                 case 'seller':
//                   return Routes.sellerHome;
//                 default:
//                   // If role is invalid, let them stay on login page
//                   return null;
//               }
//             }

//             // Make sure users can only access routes appropriate for their role
//             final goingToAdminRoute = state.matchedLocation == Routes.adminHome;
//             final goingToCustomerRoute =
//                 state.matchedLocation == Routes.customerHome;
//             final goingToSellerRoute =
//                 state.matchedLocation == Routes.sellerHome;

//             if ((goingToAdminRoute && role != 'admin') ||
//                 (goingToCustomerRoute && role != 'customer') ||
//                 (goingToSellerRoute && role != 'seller')) {
//               // Redirect to the appropriate home based on role
//               switch (role) {
//                 case 'admin':
//                   return Routes.adminHome;
//                 case 'customer':
//                   return Routes.customerHome;
//                 case 'seller':
//                   return Routes.sellerHome;
//                 default:
//                   return Routes.login;
//               }
//             }
//           }
//         } catch (e) {
//           print('Error fetching user role: $e');
//           // If there's an error, direct to login
//           return Routes.login;
//         }
//       }
//     }

//     // No redirect needed
//     return null;
//   };
// }

// One-time check for auth status
// Future<bool> _getAuthenticationStatus(BuildContext context) async {
//   final isAuthenticatedStream =
//       context.read<AuthServices>().isAuthenticatedStream;

//   final loggedIn = await isAuthenticatedStream.first;
//   return loggedIn;
// }
