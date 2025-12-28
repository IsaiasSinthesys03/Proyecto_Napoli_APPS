import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Widget para mostrar cuando una lista está vacía
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconXL * 2,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
