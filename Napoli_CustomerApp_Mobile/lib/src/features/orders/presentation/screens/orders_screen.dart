import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/orders/domain/entities/order.dart';
import 'package:go_router/go_router.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrdersCubit>()..loadOrders(),
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatelessWidget {
  const _OrdersScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOrders),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrdersError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is OrdersLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.noOrders, style: theme.textTheme.titleMedium),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.orderNumber(
                                order.id.substring(order.id.length - 6),
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusChip(theme, order.status, l10n),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.orderDate(order.date),
                          style: theme.textTheme.bodySmall,
                        ),
                        const Divider(),
                        ...order.items
                            .take(2)
                            .map(
                              (item) => Text(
                                l10n.orderItem(item.quantity, item.name),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                        if (order.items.length > 2)
                          Text(
                            l10n.moreItems(order.items.length - 2),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.total, style: theme.textTheme.titleSmall),
                            Text(
                              getIt<RestaurantConfigService>().formatPriceSync(
                                order.total,
                              ),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusChip(
    ThemeData theme,
    OrderStatus status,
    AppLocalizations l10n,
  ) {
    Color color;
    String label;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = l10n.statusPending;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        label = l10n.statusConfirmed;
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        label = l10n.statusPreparing;
        break;
      case OrderStatus.delivering:
        color = Colors.indigo;
        label = l10n.statusDelivering;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        label = l10n.statusCompleted;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = l10n.statusCancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
