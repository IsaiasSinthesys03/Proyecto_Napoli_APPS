import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../orders/presentation/widgets/order_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrdersCubit>(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar pedidos si ya está online al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<DashboardCubit>().state;
      if (state is DashboardLoaded) {
        debugPrint(
          '🔍 Dashboard Init: Driver is ${state.isOnline ? 'ONLINE' : 'OFFLINE'}. Driver ID: ${state.driver.id}',
        );

        if (state.isOnline) {
          debugPrint(
            '🚀 Dashboard: Loading orders for driver ${state.driver.id}',
          );
          context.read<OrdersCubit>().loadOrders(state.driver.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardLoaded) {
          if (state.isOnline) {
            debugPrint(
              '🚀 Dashboard Listener: Reloading orders (Online/Updated). Driver ID: ${state.driver.id}',
            );
            context.read<OrdersCubit>().loadOrders(state.driver.id);
          }
        }
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final isOnline = state is DashboardLoaded && state.isOnline;
          final driverName = state is DashboardLoaded
              ? state.driver.name
              : 'Repartidor';

          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.surfaceLight,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${driverName.split(' ')[0]} 👋',
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    isOnline ? 'Estás en línea' : 'Estás desconectado',
                    style: AppTextStyles.caption.copyWith(
                      color: isOnline
                          ? AppColors.onlineGreen
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () {
                    // Navegar a perfil
                  },
                ),
              ],
              bottom: isOnline
                  ? TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryGreen,
                      unselectedLabelColor: AppColors.textSecondaryLight,
                      indicatorColor: AppColors.primaryGreen,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'DISPONIBLES'),
                        Tab(text: 'EN CURSO'),
                      ],
                    )
                  : null,
            ),
            body: !isOnline
                ? _buildOfflineState(context)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(context, isActive: false), // Disponibles
                      _buildOrdersList(context, isActive: true), // En curso
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                context.read<DashboardCubit>().toggleOnlineStatus();
              },
              backgroundColor: isOnline
                  ? AppColors.primaryRed
                  : AppColors.onlineGreen,
              icon: Icon(
                isOnline ? Icons.power_settings_new : Icons.play_arrow,
              ),
              label: Text(isOnline ? 'DESCONECTAR' : 'CONECTAR'),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .centerDocked, // Mejor posición para evitar conflictos
          );
        },
      ),
    );
  }

  Widget _buildOfflineState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.inputFillLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.motorcycle,
              size: 80,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(
            '¿Listo para trabajar?',
            style: AppTextStyles.h2.copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Conéctate para empezar a recibir pedidos',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, {required bool isActive}) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) {
        // Cuando se actualicen las órdenes, el BlocBuilder se reconstruye automáticamente
        if (state is OrdersLoaded) {
          debugPrint(
            '📦 Dashboard _buildOrdersList: Órdenes actualizadas - Disponibles: ${state.availableOrders.length}, Activas: ${state.activeOrders.length}',
          );
        }
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading || state is OrdersInitial) {
            // Auto-recuperación: Si estamos en estado inicial y online, forzamos la carga
            if (state is OrdersInitial) {
              final dashboardState = context.read<DashboardCubit>().state;
              if (dashboardState is DashboardLoaded &&
                  dashboardState.isOnline) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (dashboardState.driver.id.length > 10) {
                    context.read<OrdersCubit>().loadOrders(
                      dashboardState.driver.id,
                    );
                  }
                });
              }
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.errorRed,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Reintentar',
                      onPressed: () {
                        final dashboardState = context
                            .read<DashboardCubit>()
                            .state;
                        if (dashboardState is DashboardLoaded) {
                          context.read<OrdersCubit>().loadOrders(
                            dashboardState.driver.id,
                          );
                        }
                      },
                      type: AppButtonType.outlined,
                      fullWidth: false,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is OrdersLoaded) {
            final orders = isActive
                ? state.activeOrders
                : state.availableOrders;

            return RefreshIndicator(
              onRefresh: () async {
                final dashboardState = context.read<DashboardCubit>().state;
                if (dashboardState is DashboardLoaded) {
                  debugPrint(
                    '🔄 Refreshing orders for driver ${dashboardState.driver.id}',
                  );
                  await context.read<OrdersCubit>().loadOrders(
                    dashboardState.driver.id,
                  );
                }
              },
              child: orders.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.local_shipping_outlined
                                        : Icons.inbox_outlined,
                                    size: 64,
                                    color: AppColors.textSecondaryLight
                                        .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isActive
                                        ? 'No tienes pedidos en curso'
                                        : 'No hay pedidos disponibles',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Desliza para actualizar',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondaryLight
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.spacingM,
                        AppDimensions.spacingM,
                        AppDimensions.spacingM,
                        80, // Espacio para el FAB
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return OrderCard(
                          order: orders[index],
                          isActive: isActive,
                        );
                      },
                    ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
