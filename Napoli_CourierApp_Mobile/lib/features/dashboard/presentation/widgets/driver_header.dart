import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/driver.dart';

/// Header del dashboard con avatar y estadísticas
class DriverHeader extends StatelessWidget {
  final Driver driver;

  const DriverHeader({required this.driver, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: driver.photoUrl != null
                ? NetworkImage(driver.photoUrl!)
                : null,
            child: driver.photoUrl == null
                ? Icon(Icons.person, size: 32, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: AppDimensions.spacingM),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: AppTextStyles.h4.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.totalDeliveries} entregas',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
