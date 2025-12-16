import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/notification_tile.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/system_permission_dialog.dart';

class GeneralSection extends StatelessWidget {
  final bool allNotifications;
  final bool systemPermissionGranted;
  final ValueChanged<bool> onChanged;
  final ValueChanged<bool> onPermissionGranted;

  const GeneralSection({
    super.key,
    required this.allNotifications,
    required this.systemPermissionGranted,
    required this.onChanged,
    required this.onPermissionGranted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.general,
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
                color: theme.shadowColor.withAlpha((0.05 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mensaje de permisos si no están otorgados
              if (!systemPermissionGranted && !allNotifications)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.permissionRequired,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              NotificationTile(
                icon: Icons.notifications,
                title: l10n.allNotifications,
                subtitle: l10n.allNotificationsSubtitle,
                value: allNotifications,
                onChanged: (value) async {
                  if (value && !systemPermissionGranted) {
                    // Mostrar popup de permisos del sistema
                    final granted =
                        await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const SystemPermissionDialog(),
                        ) ??
                        false;

                    if (granted) {
                      onPermissionGranted(true);
                      onChanged(true);
                    }
                  } else {
                    onChanged(value);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
