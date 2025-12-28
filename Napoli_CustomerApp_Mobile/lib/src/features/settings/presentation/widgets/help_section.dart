import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/settings_tile.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';

class HelpSection extends StatelessWidget {
  const HelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helpSupport,
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
              SettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpCenter,
                subtitle: l10n.helpCenterSubtitle,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () {
                  // Help center - shows coming soon placeholder
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.comingSoonHelp)));
                },
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: l10n.about,
                subtitle: l10n.version('1.0.0'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () {
                  _showAboutDialog(context, l10n);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) async {
    final name = await getIt<RestaurantConfigService>().getRestaurantName();
    
    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: name,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_pizza, size: 48),
      children: [
        Text(l10n.aboutDescription),
        const SizedBox(height: 16),
        Text(l10n.aboutFooter),
      ],
    );
  }
}

