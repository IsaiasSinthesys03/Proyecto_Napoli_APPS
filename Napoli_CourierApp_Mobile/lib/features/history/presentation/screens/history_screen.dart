import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/di/injection.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_state.dart';
import '../../domain/entities/delivery_period.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/completed_order_card.dart';

/// Pantalla de historial de entregas
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<HistoryCubit>();
        // Cargar historial del driver actual
        final dashboardState = context.read<DashboardCubit>().state;
        if (dashboardState is DashboardLoaded) {
          cubit.loadHistory(dashboardState.driver.id, DeliveryPeriod.today);
        }
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const LoadingIndicator();
            }

            if (state is HistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                  ],
                ),
              );
            }

            if (state is HistoryLoaded) {
              return Column(
                children: [
                  // Filtros
                  _buildFilters(context, state.period),

                  // Contenido scrolleable
                  Expanded(
                    child: state.orders.isEmpty
                        ? _buildEmptyState(context, state.period)
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingL,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Lista de pedidos
                                ...state.orders.map(
                                  (order) => CompletedOrderCard(
                                    order: order,
                                    onTap: () {
                                      // Navegar al detalle pasando el order completo
                                      context.go(
                                        '/dashboard/order/${order.id}',
                                        extra: order,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, DeliveryPeriod currentPeriod) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: DeliveryPeriod.values.map((period) {
          final isSelected = period == currentPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingM),
            child: FilterChip(
              label: Text(period.displayName),
              selected: isSelected,
              onSelected: (_) {
                context.read<HistoryCubit>().changePeriod(period);
              },
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DeliveryPeriod period) {
    final theme = Theme.of(context);
    String message;

    switch (period) {
      case DeliveryPeriod.today:
        message = 'No hay entregas completadas hoy';
      case DeliveryPeriod.week:
        message = 'No hay entregas completadas esta semana';
      case DeliveryPeriod.month:
        message = 'No hay entregas completadas este mes';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '¡Completa tu primera entrega!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
