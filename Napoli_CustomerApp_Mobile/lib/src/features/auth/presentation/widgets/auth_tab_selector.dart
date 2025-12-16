import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';

class AuthTabSelector extends StatelessWidget {
  final bool isSignIn;
  final ValueChanged<bool> onTabSelected;

  const AuthTabSelector({
    super.key,
    required this.isSignIn,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(true),
            child: Column(
              children: [
                Text(
                  l10n.signInTab,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSignIn
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (isSignIn)
                  Container(
                    height: 3,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(false),
            child: Column(
              children: [
                Text(
                  l10n.signUpTab,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: !isSignIn
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isSignIn)
                  Container(
                    height: 3,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
