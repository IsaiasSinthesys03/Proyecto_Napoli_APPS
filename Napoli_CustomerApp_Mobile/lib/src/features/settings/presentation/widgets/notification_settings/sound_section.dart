import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/notification_tile.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/settings_tile.dart';

class SoundSection extends StatelessWidget {
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String soundType;
  final ValueChanged<bool> onSoundEnabledChanged;
  final ValueChanged<bool> onVibrationEnabledChanged;
  final ValueChanged<String> onSoundTypeChanged;

  const SoundSection({
    super.key,
    required this.enabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.soundType,
    required this.onSoundEnabledChanged,
    required this.onVibrationEnabledChanged,
    required this.onSoundTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.soundVibration,
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
              NotificationTile(
                icon: Icons.volume_up,
                title: l10n.sound,
                subtitle: l10n.soundSubtitle,
                value: soundEnabled,
                onChanged: enabled ? onSoundEnabledChanged : null,
              ),
              SettingsTile(
                icon: Icons.music_note,
                title: l10n.notificationTone,
                subtitle: _getSoundTypeName(context, soundType),
                onTap: (enabled && soundEnabled)
                    ? () {
                        _showSoundPicker(context, theme);
                      }
                    : null,
                trailing: Icon(
                  Icons.chevron_right,
                  color: (enabled && soundEnabled)
                      ? theme.colorScheme.onSurface.withAlpha(
                          (0.5 * 255).round(),
                        )
                      : theme.colorScheme.onSurface.withAlpha(
                          (0.2 * 255).round(),
                        ),
                ),
              ),
              NotificationTile(
                icon: Icons.vibration,
                title: l10n.vibration,
                subtitle: l10n.vibrationSubtitle,
                value: vibrationEnabled,
                onChanged: enabled ? onVibrationEnabledChanged : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSoundTypeName(BuildContext context, String soundType) {
    final l10n = AppLocalizations.of(context)!;
    switch (soundType) {
      case 'default':
        return l10n.defaultTone;
      case 'bell':
        return l10n.bellTone;
      case 'chime':
        return l10n.chimeTone;
      case 'notification':
        return l10n.notificationLabel;
      default:
        return l10n.defaultTone;
    }
  }

  void _showSoundPicker(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectTone,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._getSoundOptions(context).map(
              (option) => ListTile(
                title: Text(option['name']!),
                leading: Radio<String>(
                  value: option['value']!,
                  groupValue: soundType,
                  onChanged: (value) {
                    onSoundTypeChanged(value!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  onSoundTypeChanged(option['value']!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getSoundOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'name': l10n.defaultTone, 'value': 'default'},
      {'name': l10n.bellTone, 'value': 'bell'},
      {'name': l10n.chimeTone, 'value': 'chime'},
      {'name': l10n.notificationLabel, 'value': 'notification'},
    ];
  }
}
