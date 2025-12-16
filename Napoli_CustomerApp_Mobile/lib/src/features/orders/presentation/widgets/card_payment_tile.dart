import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';

class CardPaymentTile extends StatelessWidget {
  final PaymentMethodModel card;
  final PaymentMethodModel? selectedCard;
  final String selectedPaymentMethod;
  final ValueChanged<PaymentMethodModel> onCardSelected;

  const CardPaymentTile({
    super.key,
    required this.card,
    required this.selectedCard,
    required this.selectedPaymentMethod,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedCard?.id == card.id;

    return InkWell(
      onTap: () => onCardSelected(card),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
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
                color: _getCardColor(
                  card.cardBrand ?? 'default',
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.credit_card,
                color: _getCardColor(card.cardBrand ?? 'default'),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${card.cardBrand ?? 'Card'} ${card.cardNumber ?? '****'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (card.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Predeterminada',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    card.cardHolder ?? 'N/A',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: 'card_${card.id}',
              groupValue: isSelected
                  ? 'card_${card.id}'
                  : selectedPaymentMethod,
              onChanged: (newValue) => onCardSelected(card),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(String? cardBrand) {
    switch ((cardBrand ?? 'default').toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A237E);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
