import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';

class AuthFooter extends StatelessWidget {
  final bool isSignIn;
  final VoidCallback onTap;

  const AuthFooter({super.key, required this.isSignIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Text(
        isSignIn
            ? '${l10n.dontHaveAccount} ${l10n.registerAction}'
            : '${l10n.alreadyHaveAccount} ${l10n.loginAction}',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
