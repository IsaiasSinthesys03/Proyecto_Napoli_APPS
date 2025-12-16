import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/pressable_scale.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(l10n.orLoginWith, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _socialButtonColored(
                context,
                Icons.email_outlined,
                'Google',
                AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _socialButtonColored(
                context,
                Icons.facebook_outlined,
                'Facebook',
                AppColors.primaryRed,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _socialButtonColored(
                context,
                Icons.apple,
                'Apple',
                AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _socialButtonColored(
    BuildContext context,
    IconData icon,
    String label,
    Color bgColor,
  ) {
    return PressableScale(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label login coming soon!'))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
