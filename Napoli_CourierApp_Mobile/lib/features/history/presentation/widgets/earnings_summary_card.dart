import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';

/// Card que muestra el resumen de ganancias
class EarningsSummaryCard extends StatelessWidget {
  final double totalEarnings;
  final int deliveryCount;
  final double averageEarnings;

  const EarningsSummaryCard({
    required this.totalEarnings,
    required this.deliveryCount,
    required this.averageEarnings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.white, size: 24),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Ganancias',
                style: AppTextStyles.h4.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            '\$${totalEarnings.toStringAsFixed(0)}',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              Text(
                '$deliveryCount entregas',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                '•',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Text(
                '\$${averageEarnings.toStringAsFixed(0)} promedio',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
