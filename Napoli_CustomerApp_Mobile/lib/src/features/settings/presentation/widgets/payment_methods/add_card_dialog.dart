import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/utils/card_input_formatters.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/payment_method.dart';

class AddCardDialog extends StatefulWidget {
  final PaymentMethodModel? paymentMethod;
  final Function(PaymentMethodModel) onSave;

  const AddCardDialog({super.key, this.paymentMethod, required this.onSave});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.paymentMethod != null;
    _cardNumberController = TextEditingController(
      text: isEditing
          ? (widget.paymentMethod!.cardNumber ?? '')
                .replaceAll('*', '')
                .replaceAll(' ', '')
          : '',
    );
    _cardHolderController = TextEditingController(
      text: widget.paymentMethod?.cardHolder ?? '',
    );
    _expiryController = TextEditingController(
      text: widget.paymentMethod?.expiryDate ?? '',
    );
    _cvvController = TextEditingController();
    _isDefault = widget.paymentMethod?.isDefault ?? false;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentMethod != null;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? l10n.editCardTitle : l10n.addCardTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Número de tarjeta
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: l10n.cardNumberLabel,
                hintText: '1234 5678 9012 3456',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                CardNumberInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),

            // Titular
            TextField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: l10n.cardHolderNameLabel,
                hintText: 'JUAN PEREZ',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Fecha de expiración y CVV
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: l10n.expiryDateLabel,
                      hintText: 'MM/AA',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      ExpiryDateInputFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: l10n.cvvLabel,
                      hintText: '123',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hacer predeterminada
            CheckboxListTile(
              title: Text(l10n.setAsDefaultLabel),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 8),

            // Información de seguridad
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.securityInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: Text(isEditing ? 'Actualizar' : 'Agregar'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_cardNumberController.text.length >= 16 &&
        _cardHolderController.text.isNotEmpty &&
        _expiryController.text.length == 5 &&
        _cvvController.text.length >= 3) {
      final cardBrand = _getCardBrand(_cardNumberController.text);
      final maskedCardNumber = _maskCardNumber(_cardNumberController.text);

      final newPaymentMethod = PaymentMethodModel(
        id: widget.paymentMethod?.id ?? const Uuid().v4(),
        type: PaymentType.card,
        cardNumber: maskedCardNumber,
        cardHolder: _cardHolderController.text.toUpperCase(),
        expiryDate: _expiryController.text,
        cardBrand: cardBrand,
        isDefault: _isDefault,
      );

      widget.onSave(newPaymentMethod);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getCardBrand(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5') || number.startsWith('2')) return 'Mastercard';
    if (number.startsWith('3')) return 'Amex';
    return 'Tarjeta';
  }

  String _maskCardNumber(String cardNumber) {
    final number = cardNumber.replaceAll(' ', '');
    if (number.length >= 4) {
      final lastFour = number.substring(number.length - 4);
      return '**** **** **** $lastFour';
    }
    return cardNumber;
  }
}
