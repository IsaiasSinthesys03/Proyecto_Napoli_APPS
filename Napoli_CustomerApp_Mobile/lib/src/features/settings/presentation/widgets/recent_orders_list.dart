import 'package:flutter/material.dart';
import '../../domain/entities/order_history.dart';
import 'order_history_card.dart';

class RecentOrdersList extends StatelessWidget {
  final List<OrderHistory> orders;
  final Function(OrderHistory) onTap;
  final Function(OrderHistory) onReorder;
  final Function(OrderHistory) onTrack;
  final Function(OrderHistory, int) onRate;

  const RecentOrdersList({
    super.key,
    required this.orders,
    required this.onTap,
    required this.onReorder,
    required this.onTrack,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderHistoryCard(
          order: order,
          onTap: () => onTap(order),
          onReorder: () => onReorder(order),
          onTrack: () => onTrack(order),
          onRate: (rating) => onRate(order, rating),
        );
      },
    );
  }
}
