import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/notification_tile.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/settings_tile.dart';

class QuietHoursSection extends StatelessWidget {
  final bool enabled;
  final bool quietHoursEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<bool> onQuietHoursChanged;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const QuietHoursSection({
    super.key,
    required this.enabled,
    required this.quietHoursEnabled,
    required this.startTime,
    required this.endTime,
    required this.onQuietHoursChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.doNotDisturb,
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
                icon: Icons.do_not_disturb,
                title: l10n.quietHours,
                subtitle: l10n.quietHoursSubtitle,
                value: quietHoursEnabled,
                onChanged: enabled ? onQuietHoursChanged : null,
              ),
              if (quietHoursEnabled && enabled) ...[
                SettingsTile(
                  icon: Icons.access_time,
                  title: l10n.startTime,
                  subtitle: _formatTime(startTime),
                  onTap: () => _selectTime(context, true),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.5 * 255).round(),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.access_time_filled,
                  title: l10n.endTime,
                  subtitle: _formatTime(endTime),
                  onTap: () => _selectTime(context, false),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withAlpha(
                      (0.5 * 255).round(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? startTime : endTime;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      if (isStartTime) {
        onStartTimeChanged(time);
      } else {
        onEndTimeChanged(time);
      }
    }
  }
}
