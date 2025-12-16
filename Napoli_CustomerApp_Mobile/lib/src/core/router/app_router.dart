import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/screens/login_screen.dart';
import 'package:napoli_app_v1/src/features/home/presentation/screens/home_screen.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/screens/cart_screen.dart';
import 'package:napoli_app_v1/src/features/splash/presentation/screens/splash_screen.dart';
import 'package:napoli_app_v1/src/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:napoli_app_v1/src/features/orders/presentation/screens/order_placed_screen.dart';
import 'package:napoli_app_v1/src/features/orders/presentation/screens/orders_screen.dart';
import 'package:napoli_app_v1/src/core/core_ui/screens/global_error_screen.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/screens/detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) => const OrderConfirmationScreen(),
    ),
    GoRoute(
      path: '/order-placed',
      builder: (context, state) => const OrderPlacedScreen(),
    ),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/error',
      builder: (context, state) {
        final error = state.extra;
        return GlobalErrorScreen(error: error);
      },
    ),
  ],
);
