import 'package:go_router/go_router.dart';
import 'package:mycrochetbag/data/repositories/auth/firestore_user_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/ui/authentication/forgot_password/widgets/reset_password_screen.dart';
import 'package:mycrochetbag/ui/authentication/change_password/widget/change_password_screen.dart';
import 'package:mycrochetbag/ui/authentication/login/view_model/login_viewmodel.dart';
import 'package:mycrochetbag/ui/customer/customer_cart/widget/customer_cart_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_custom/widget/customer_custom_order_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_homepage/home/widgets/customer_homepage_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_order/widgets/customer_order_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_homepage/widgets/seller_homepage_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_order/widget/seller_order_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_product/widget/seller_product_screen.dart';
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
import 'package:mycrochetbag/ui/customer/customer_profile/customer_profile_screen.dart';
import 'package:mycrochetbag/ui/admin/widgets/admin_profile_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_bag/seller_add_bag/widget/seller_addbag_screen.dart';
import 'package:mycrochetbag/ui/seller/seller_manage_bag/seller_preview_bag/widgets/seller_previewBag_screen.dart';
import 'package:mycrochetbag/ui/customer/customer_profile/customer_edit_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router(AuthServices authServices) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  redirect: buildRedirect(authServices),
  initialLocation: Routes.login,
  debugLogDiagnostics: true,
  refreshListenable: authServices,
  routes: [
    GoRoute(path: '/', name: '/', redirect: (context, state) => Routes.login),
    GoRoute(
      path: Routes.login,
      builder:
          (context, state) =>
              LoginScreen(viewModel: LoginViewModel(context.read())),
    ),
    GoRoute(
      path: Routes.home,
      builder:
          (context, state) =>
              LoginScreen(viewModel: LoginViewModel(context.read())),
    ),
    GoRoute(
      path: Routes.signUp,
      builder:
          (context, state) =>
              SignUpScreen(viewModel: SignUpViewmodel(context.read())),
    ),
    GoRoute(
      path: Routes.changePassword,
      builder: (context, state) => ChangePasswordScreen(),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) {
        final oobCode = state.uri.queryParameters['oobCode'] ?? '';
        return ResetPasswordScreen(oobCode: oobCode);
      },
    ),

    /// Customer Route
    ShellRoute(
      builder: (context, state, child) {
        return CustomerMainScreen(child: child); // shared layout
      },
      routes: [
        GoRoute(
          path: Routes.customerHome,
          builder: (context, state) => const CustomerHomepageScreen(),
        ),
        GoRoute(
          path: Routes.customerCustomOrder,
          builder: (context, state) => const CustomerCustomOrderScreen(),
        ),
        GoRoute(
          path: Routes.customerCart,
          builder: (context, state) => const CustomerCartScreen(),
        ),
        GoRoute(
          path: Routes.customerOrders,
          builder: (context, state) => const CustomerOrderScreen(),
        ),
        GoRoute(
          path: Routes.customerProfile,
          builder: (context, state) => const CustomerProfileScreen(),
        ),
        GoRoute(
          path: Routes.customerEditProfile,
          builder: (context, state) => const CustomerEditProfileScreen(),
        ),
      ],
    ),

    /// Admin Route
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
        GoRoute(
          path: Routes.adminProfile, // /admin/profile
          builder: (context, state) => const AdminProfileScreen(),
        ),
      ],
    ),

    /// Seller Route
    ShellRoute(
      builder: (context, state, child) {
        return SellerMainScreen(child: child); // shared layout
      },
      routes: [
        GoRoute(
          path: Routes.sellerHome, // /seller/home
          builder: (context, state) => const SellerHomepageScreen(),
        ),
        GoRoute(
          path: Routes.sellerProduct, // /seller/product
          builder: (context, state) => const SellerProductScreen(),
        ),
        GoRoute(
          path: Routes.sellerOrders, // /seller/order
          builder: (context, state) => const SellerOrderScreen(),
        ),
        GoRoute(
          path: Routes.sellerProfile, // /seller/profile
          builder: (context, state) => const SellerProfileScreen(),
        ),
        GoRoute(
          path: Routes.sellerAddBag, // '/seller/add-bag'
          builder: (context, state) => AddProductPage(),
        ),
        GoRoute(
          path: Routes.sellerPreviewBag, // '/seller/preview-bag'
          builder:
              (context, state) => const SellerPreviewBagScreen(
                productId: '',
              ), // Or with data if needed
        ),
      ],
    ),
    // GoRoute(
    //   path: Routes.sellerHome,
    //   builder: (context, state) => const SellerMainScreen(),
    // ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Error: Route not found\nUri: ${state.uri}\nMatched: ${state.matchedLocation}',
          ),
        ),
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
