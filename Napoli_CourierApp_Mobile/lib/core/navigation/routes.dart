/// Route path constants
class AppRoutes {
  // Auth routes
  static const login = '/login';
  static const register = '/register';
  static const pendingApproval = '/pending-approval';

  // Main routes
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const history = '/history';

  // Nested routes
  static const orderDetail = 'order/:id';
  static const editProfile = 'edit';

  // Full paths for navigation
  static String orderDetailPath(String orderId) => '/dashboard/order/$orderId';
}
