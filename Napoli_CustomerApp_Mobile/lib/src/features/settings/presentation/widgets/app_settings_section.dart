import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme_provider.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/settings_tile.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = ThemeProvider.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appSettings,
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
                icon: Icons.dark_mode,
                title: l10n.darkMode,
                subtitle: l10n.darkModeSubtitle,
                trailing: Switch(
                  value: themeController.dark,
                  onChanged: (_) => themeController.toggle(),
                  activeTrackColor: theme.colorScheme.primary,
                ),
              ),
              SettingsTile(
                icon: Icons.notifications,
                title: l10n.notifications,
                subtitle: l10n.notificationsSubtitle,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: l10n.languageSubtitle,
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () {
                  // Language settings - shows coming soon placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoonLanguage)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
