import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../orders/domain/entities/order.dart';

/// Card que muestra un pedido completado
class CompletedOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const CompletedOrderCard({
    required this.order,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Número y badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber,
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Entregado',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Fecha y hora
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${timeFormat.format(order.deliveredAt!.toLocal())} - ${dateFormat.format(order.deliveredAt!.toLocal())}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),

              // Cliente
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Footer: Solo flecha
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
