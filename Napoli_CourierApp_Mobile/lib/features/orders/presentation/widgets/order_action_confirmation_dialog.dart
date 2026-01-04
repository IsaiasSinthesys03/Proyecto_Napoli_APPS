import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/order_status.dart';

/// Diálogo de confirmación para acciones de cambio de estado del pedido
class OrderActionConfirmationDialog extends StatelessWidget {
  final OrderStatus currentStatus;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const OrderActionConfirmationDialog({
    super.key,
    required this.currentStatus,
    required this.onConfirm,
    required this.onCancel,
  });

  String get _getTitle {
    switch (currentStatus) {
      case OrderStatus.ready:
        return '¿Aceptar pedido?';
      case OrderStatus.accepted:
        return '¿Confirmar recogida?';
      case OrderStatus.delivering:
        return '¿Marcar como entregado?';
      default:
        return '¿Confirmar acción?';
    }
  }

  String get _getDescription {
    switch (currentStatus) {
      case OrderStatus.ready:
        return 'Asegúrate de estar en el restaurante antes de aceptar este pedido.';
      case OrderStatus.accepted:
        return 'Confirma que has recogido el pedido del restaurante.';
      case OrderStatus.delivering:
        return 'Asegúrate de que el cliente ha recibido el pedido correctamente.';
      default:
        return '¿Deseas continuar con esta acción?';
    }
  }

  String get _getConfirmButtonText {
    switch (currentStatus) {
      case OrderStatus.ready:
        return 'Aceptar Pedido';
      case OrderStatus.accepted:
        return 'Confirmar Recogida';
      case OrderStatus.delivering:
        return 'Marcar Entregado';
      default:
        return 'Confirmar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(child: Text(_getTitle, style: AppTextStyles.h3)),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Descripción
            Text(
              _getDescription,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppDimensions.spacingXL),

            // Botones
            Row(
              children: [
                // Botón Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onCancel();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingM,
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Text(
                      'Cancelar',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),

                // Botón Confirmar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingM,
                      ),
                    ),
                    child: Text(
                      _getConfirmButtonText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
