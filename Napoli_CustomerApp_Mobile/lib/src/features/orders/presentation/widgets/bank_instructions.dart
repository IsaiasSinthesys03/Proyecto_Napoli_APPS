import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BankInstructions extends StatelessWidget {
  final Map<String, String> bankData;

  const BankInstructions({super.key, required this.bankData});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado al portapapeles'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos Bancarios',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildBankDataTile(
                context,
                theme,
                icon: Icons.account_balance,
                label: 'Banco',
                value: bankData['banco']!,
                onCopy: () =>
                    _copyToClipboard(context, bankData['banco']!, 'Banco'),
              ),
              const Divider(height: 1),
              _buildBankDataTile(
                context,
                theme,
                icon: Icons.person_outline,
                label: 'Titular',
                value: bankData['titular']!,
                onCopy: () =>
                    _copyToClipboard(context, bankData['titular']!, 'Titular'),
              ),
              const Divider(height: 1),
              _buildBankDataTile(
                context,
                theme,
                icon: Icons.pin,
                label: 'CLABE',
                value: bankData['clabe']!,
                onCopy: () =>
                    _copyToClipboard(context, bankData['clabe']!, 'CLABE'),
                isMonospace: true,
              ),
              const Divider(height: 1),
              _buildBankDataTile(
                context,
                theme,
                icon: Icons.credit_card,
                label: 'Cuenta',
                value: bankData['cuenta']!,
                onCopy: () =>
                    _copyToClipboard(context, bankData['cuenta']!, 'Cuenta'),
                isMonospace: true,
              ),
              const Divider(height: 1),
              _buildBankDataTile(
                context,
                theme,
                icon: Icons.receipt_long,
                label: 'Concepto',
                value: bankData['concepto']!,
                onCopy: () => _copyToClipboard(
                  context,
                  bankData['concepto']!,
                  'Concepto',
                ),
                isMonospace: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDataTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onCopy,
    bool isMonospace = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
          fontFamily: isMonospace ? 'monospace' : null,
        ),
      ),
      trailing: IconButton(
        onPressed: onCopy,
        icon: const Icon(Icons.copy),
        tooltip: 'Copiar',
        color: theme.colorScheme.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
