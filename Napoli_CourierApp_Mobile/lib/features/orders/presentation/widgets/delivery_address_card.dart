import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../domain/entities/delivery_address.dart';

/// Card con dirección de entrega y botón de navegación
class DeliveryAddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final VoidCallback? onNavigatePressed; // Opcional para ocultar botón

  const DeliveryAddressCard({
    required this.address,
    this.onNavigatePressed, // Ahora es opcional
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.navigationBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.navigationBlue,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Dirección de Entrega',
                style: AppTextStyles.h4.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Dirección
          Text(
            address.fullAddress,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          // Notas
          if (address.notes != null && address.notes!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.warningOrange,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      address.notes!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingM),

          // Botón navegar (solo si se proporciona callback)
          if (onNavigatePressed != null)
            AppButton(
              label: 'Navegar',
              icon: Icons.navigation,
              type: AppButtonType.secondary,
              onPressed: onNavigatePressed!,
            ),
        ],
      ),
    );
  }
}
