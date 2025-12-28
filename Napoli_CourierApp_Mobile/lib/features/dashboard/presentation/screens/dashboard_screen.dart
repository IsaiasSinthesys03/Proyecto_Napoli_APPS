import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/phone_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../orders/presentation/widgets/order_card.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/driver_header.dart';
import '../widgets/online_status_switch.dart';

/// Pantalla principal del dashboard
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final OrdersCubit _ordersCubit;
  bool _ordersLoaded = false;

  @override
  void initState() {
    super.initState();
    _ordersCubit = getIt<OrdersCubit>();
  }

  @override
  void dispose() {
    _ordersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _ordersCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // TODO: Implementar logout
              },
            ),
          ],
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboardState) {
            if (dashboardState is DashboardInitial) {
              return const LoadingIndicator();
            }

            if (dashboardState is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      dashboardState.message,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              );
            }

            if (dashboardState is DashboardLoaded) {
              // Cargar pedidos solo una vez
              if (!_ordersLoaded) {
                _ordersLoaded = true;
                print(
                  '🟢 Dashboard loaded, loading orders for driver: ${dashboardState.driver.id}',
                );
                Future.microtask(() {
                  _ordersCubit.loadOrders(dashboardState.driver.id);
                });
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<DashboardCubit>().initialize(
                    dashboardState.driver,
                  );
                  await _ordersCubit.loadOrders(dashboardState.driver.id);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header con info del driver
                      DriverHeader(driver: dashboardState.driver),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Switch Online/Offline
                      OnlineStatusSwitch(
                        isOnline: dashboardState.isOnline,
                        onToggle: () {
                          context.read<DashboardCubit>().toggleOnlineStatus();
                        },
                      ),
                      const SizedBox(height: AppDimensions.spacingL),

                      // Lista de pedidos
                      BlocBuilder<OrdersCubit, OrdersState>(
                        builder: (context, ordersState) {
                          print(
                            '🔷 BlocBuilder rebuilding with state: ${ordersState.runtimeType}',
                          );

                          if (ordersState is OrdersLoading) {
                            print('🔷 Showing loading indicator');
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  AppDimensions.spacingXL,
                                ),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (ordersState is OrdersLoaded) {
                            print(
                              '🔷 OrdersLoaded: ${ordersState.availableOrders.length} available, ${ordersState.activeOrders.length} active',
                            );
                            final hasOrders =
                                ordersState.availableOrders.isNotEmpty ||
                                ordersState.activeOrders.isNotEmpty;

                            if (!hasOrders) {
                              print('🔷 No orders, showing empty state');
                              return _buildEmptyState(
                                context,
                                dashboardState.isOnline,
                              );
                            }

                            print(
                              '🔷 Rendering ${ordersState.availableOrders.length} available orders',
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Pedidos activos
                                if (ordersState.activeOrders.isNotEmpty) ...[
                                  Text(
                                    'En Curso',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingM,
                                  ),
                                  ...ordersState.activeOrders.map(
                                    (order) => OrderCard(
                                      order: order,
                                      onTap: () => _navigateToOrderDetail(
                                        context,
                                        order.id,
                                        dashboardState.driver.id,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingL,
                                  ),
                                ],

                                // Pedidos disponibles
                                if (ordersState.availableOrders.isNotEmpty) ...[
                                  Text(
                                    'Disponibles',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingM,
                                  ),
                                  ...ordersState.availableOrders.map(
                                    (order) => OrderCard(
                                      order: order,
                                      onTap: () => _navigateToOrderDetail(
                                        context,
                                        order.id,
                                        dashboardState.driver.id,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }

                          return _buildEmptyState(
                            context,
                            dashboardState.isOnline,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isOnline) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            isOnline
                ? 'Esperando pedidos...'
                : 'Conéctate para recibir pedidos',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetail(
    BuildContext context,
    String orderId,
    String driverId,
  ) {
    print('🟡 Navigating to order detail: $orderId for driver: $driverId');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          print('🟡 Building OrderDetailScreen for order: $orderId');
          return BlocProvider(
            create: (_) => getIt<OrdersCubit>()..loadOrderDetail(orderId),
            child: OrderDetailScreen(
              orderId: orderId,
              driverId: driverId,
              phoneService: getIt<PhoneService>(),
              navigationService: getIt<NavigationService>(),
            ),
          );
        },
      ),
    );
  }
}
