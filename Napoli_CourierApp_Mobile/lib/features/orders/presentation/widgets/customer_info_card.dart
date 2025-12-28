import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/pressable_scale.dart';

/// Card con información del cliente y botón de llamada
class CustomerInfoCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onCallPressed; // Opcional para ocultar botón

  const CustomerInfoCard({
    required this.name,
    required this.phone,
    this.onCallPressed, // Ahora es opcional
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
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: AppDimensions.spacingM),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h4.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  phone,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Botón llamar (solo si se proporciona callback)
          if (onCallPressed != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCallPressed,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
