import 'package:flutter/material.dart';
import '../../../../../../l10n/arb/app_localizations.dart';

class PaymentActionButton extends StatelessWidget {
  final bool isProcessing;
  final String paymentMethod;
  final VoidCallback? onPressed;

  const PaymentActionButton({
    super.key,
    required this.isProcessing,
    required this.paymentMethod,
    this.onPressed,
  });

  String _getButtonText(BuildContext context) {
    if (isProcessing) return '';
    final l10n = AppLocalizations.of(context)!;

    if (paymentMethod == 'transferencia') {
      return 'Confirmar Transferencia';
    } else if (paymentMethod == 'card') {
      return 'Pagar con Tarjeta';
    }
    return l10n.confirmOrder;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          disabledBackgroundColor: theme.disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isProcessing
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onSecondary,
                  ),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _getButtonText(context),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
      ),
    );
  }
}
