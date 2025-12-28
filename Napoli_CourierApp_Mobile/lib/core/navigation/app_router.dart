import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/pending_approval_screen.dart';
import '../../features/auth/domain/entities/driver.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/domain/entities/driver_profile.dart';
import '../di/injection.dart';
import '../services/phone_service.dart';
import '../services/navigation_service.dart';
import 'routes.dart';
import 'bottom_nav_scaffold.dart';

/// Global router configuration for the app
final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    // Auth routes (no bottom nav)
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.pendingApproval,
      builder: (context, state) {
        // Get driver from extra parameter
        final driver = state.extra as Driver?;
        if (driver == null) {
          // If no driver, redirect to login
          return const LoginScreen();
        }
        return PendingApprovalScreen(driver: driver);
      },
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
              routes: [
                // Nested route: Order Detail
                GoRoute(
                  path: AppRoutes.orderDetail,
                  builder: (context, state) {
                    final orderId = state.pathParameters['id']!;
                    final driverId =
                        state.uri.queryParameters['driverId'] ?? '1';

                    // Get order from extra if navigating from history
                    final order = state.extra as Order?;

                    return OrderDetailScreen(
                      orderId: orderId,
                      driverId: driverId,
                      order: order, // Pass order if available
                      phoneService: getIt<PhoneService>(),
                      navigationService: getIt<NavigationService>(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // Branch 2: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),

        // Branch 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                // Nested route: Edit Profile
                GoRoute(
                  path: AppRoutes.editProfile,
                  builder: (context, state) {
                    final profile = state.extra as DriverProfile;
                    return BlocProvider.value(
                      value: getIt<ProfileCubit>(),
                      child: EditProfileScreen(profile: profile),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
