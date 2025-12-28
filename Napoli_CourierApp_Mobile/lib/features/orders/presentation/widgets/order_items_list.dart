import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/order_item.dart';

/// Lista de items del pedido
class OrderItemsList extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItemsList({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items del Pedido',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),

          ...items.map((item) => _buildItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, OrderItem item) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cantidad
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),

          // Nombre y notas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    item.notes!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Precio
          Text(
            '\$${item.price.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
