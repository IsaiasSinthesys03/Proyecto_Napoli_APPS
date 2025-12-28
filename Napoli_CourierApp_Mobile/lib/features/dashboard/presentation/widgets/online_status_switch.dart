import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';

/// Switch grande para cambiar estado online/offline
class OnlineStatusSwitch extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const OnlineStatusSwitch({
    required this.isOnline,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          color: isOnline
              ? AppColors.onlineGreen.withValues(alpha: 0.1)
              : AppColors.offlineGray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isOnline ? AppColors.onlineGreen : AppColors.offlineGray,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Indicador circular
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.onlineGreen : AppColors.offlineGray,
                boxShadow: isOnline
                    ? [
                        BoxShadow(
                          color: AppColors.onlineGreen.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? 'EN LÍNEA' : 'DESCONECTADO',
                    style: AppTextStyles.h3.copyWith(
                      color: isOnline
                          ? AppColors.onlineGreen
                          : AppColors.offlineGray,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    isOnline
                        ? 'Recibirás pedidos disponibles'
                        : 'No recibirás nuevos pedidos',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Switch
            Switch(
              value: isOnline,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.onlineGreen,
              inactiveThumbColor: AppColors.offlineGray,
            ),
          ],
        ),
      ),
    );
  }
}
