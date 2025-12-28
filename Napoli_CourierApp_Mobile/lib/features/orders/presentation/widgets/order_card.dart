import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/pressable_scale.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

/// Card para mostrar un pedido en la lista
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({required this.order, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    print('🟦 OrderCard building for order: ${order.orderNumber}');
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          print('🔵 OrderCard tapped: ${order.orderNumber} (ID: ${order.id})');
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Número y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Dirección
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      order.deliveryAddress.street,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),

              // Info: Distancia y ganancia
              Row(
                children: [
                  Icon(Icons.route, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${order.distanceKm} km',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppColors.successGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${order.driverEarnings.toStringAsFixed(0)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.available:
        return AppColors.navigationBlue;
      case OrderStatus.accepted:
        return AppColors.warningOrange;
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        return AppColors.primaryGreen;
      case OrderStatus.delivered:
        return AppColors.successGreen;
      case OrderStatus.cancelled:
        return AppColors.errorRed;
    }
  }
}
