abstract final class Routes {
  // General Route for all
  static const home = '/';
  static const login = '/login';
  static const signUp = '/signup';
  static const resetPassword = '/reset-password';
  static const changePassword = '/change-password';

  // Customer Route
  static const customerHome = '/customer/home';
  static const customerCustomOrder = '/customer/custom';
  static const customerCart = '/customer/carts';
  static const customerOrders = '/customer/orders';
  static const customerProfile = '/customer/profile';
  static const customerEditProfile = '/customer/edit-profile';

  // Seller Route
  static const sellerHome = '/seller/home';
  static const sellerProfile = '/seller/profile';
  static const sellerProduct = '/seller/products';
  static const sellerOrders = '/seller/orders';
  static const sellerAddBag = '/seller/add-bag';
  static const sellerEditBag = '/seller/edit-bag';
  static const sellerPreviewBag = '/seller/preview-bag';

  // Admin Route
  static const adminHome = '/admin/home';
  static const viewAllUser = '/admin/user';
  static const addUser = '/admin/user/add';
  static const userDetails = '/admin/user/:userId';
  static const adminProfile = '/admin/profile';
}
