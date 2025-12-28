import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';
import 'pressable_scale.dart';

/// Tipos de botones disponibles
enum AppButtonType {
  primary, // Rojo CTA
  secondary, // Verde corporativo
  success, // Verde éxito
  outlined, // Borde verde
}

/// Botón estandarizado de la aplicación
/// Incluye feedback táctil y estados de carga
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonType type;
  final bool fullWidth;

  const AppButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = AppButtonType.primary,
    this.fullWidth = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimensions.iconMedium),
                const SizedBox(width: AppDimensions.spacingS),
              ],
              Text(label),
            ],
          );

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              AppDimensions.buttonHeight,
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.secondary:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              AppDimensions.buttonHeight,
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.success:
        button = FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              AppDimensions.buttonHeight,
            ),
          ),
          child: buttonChild,
        );
        break;

      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(
              fullWidth ? double.infinity : 0,
              AppDimensions.buttonHeight,
            ),
          ),
          child: buttonChild,
        );
        break;
    }

    return PressableScale(child: button);
  }
}
