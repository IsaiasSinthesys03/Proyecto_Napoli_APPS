import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';
import 'payment_option_tile.dart';
import 'card_payment_tile.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedPaymentMethod;
  final bool transferConfirmed;
  final PaymentMethodModel? selectedCard;
  final List<PaymentMethodModel> savedCards;
  final bool enableSavedCards;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<PaymentMethodModel> onCardSelected;
  final VoidCallback onTransferTap;

  const PaymentMethodSelector({
    super.key,
    required this.selectedPaymentMethod,
    required this.transferConfirmed,
    required this.selectedCard,
    required this.savedCards,
    required this.enableSavedCards,
    required this.onMethodChanged,
    required this.onCardSelected,
    required this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Método de Pago',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Opciones de método de pago
          Column(
            children: [
              // Efectivo
              // Efectivo
              PaymentOptionTile(
                value: 'efectivo',
                title: 'Efectivo',
                subtitle: 'Pagar al recibir el pedido',
                icon: Icons.money,
                iconColor: Colors.green,
                selectedValue: selectedPaymentMethod,
                onMethodChanged: onMethodChanged,
              ),

              const SizedBox(height: 8),

              // Transferencia
              InkWell(
                onTap: onTransferTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selectedPaymentMethod == 'transferencia'
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    border: Border.all(
                      color: selectedPaymentMethod == 'transferencia'
                          ? theme.colorScheme.primary
                          : theme.dividerColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (transferConfirmed ? Colors.green : Colors.blue)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: transferConfirmed ? Colors.green : Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transferConfirmed
                                  ? 'Transferencia Confirmada ✓'
                                  : 'Transferencia',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: selectedPaymentMethod == 'transferencia'
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              transferConfirmed
                                  ? 'Comprobante adjuntado correctamente'
                                  : 'SPEI o transferencia bancaria',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: 'transferencia',
                        groupValue: selectedPaymentMethod,
                        onChanged:
                            null, // Deshabilitar, el tap lo maneja InkWell
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Tarjetas guardadas
              if (enableSavedCards && savedCards.isNotEmpty) ...[
                ...savedCards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CardPaymentTile(
                      card: card,
                      selectedCard: selectedCard,
                      selectedPaymentMethod: selectedPaymentMethod,
                      onCardSelected: onCardSelected,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
