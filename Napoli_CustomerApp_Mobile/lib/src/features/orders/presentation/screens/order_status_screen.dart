import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/features/orders/domain/entities/order.dart';
import 'package:napoli_app_v1/src/features/orders/presentation/widgets/pizza_order_tracker.dart';

class OrderStatusScreen extends StatelessWidget {
  final Order order;

  const OrderStatusScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderStatus)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              l10n.orderNumber(order.id.substring(order.id.length - 6)),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 30),
            PizzaOrderTracker(
              currentStep: _mapStatusToStep(order.status),
              activeColor: Colors.green,
            ),
            if (order.status == OrderStatus.delivering) ...[
              const SizedBox(height: 30),
              const _DriverInfoCard(),
            ],
          ],
        ),
      ),
    );
  }

  int _mapStatusToStep(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.delivering:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return 0;
    }
  }
}

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourDeliveryMan,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marco Antonio', // Mock name
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Llamando al repartidor...')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
