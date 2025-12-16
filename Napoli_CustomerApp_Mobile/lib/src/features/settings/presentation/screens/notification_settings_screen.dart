import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/general_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/notification_types_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/quiet_hours_section.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/widgets/notification_settings/sound_section.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:napoli_app_v1/src/features/settings/presentation/cubit/notification_settings_cubit.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/notification_settings.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<NotificationSettingsCubit>()..loadSettings(),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
        builder: (context, state) {
          if (state is NotificationSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is NotificationSettingsError) {
             return Center(child: Text(state.message));
          }

          if (state is NotificationSettingsLoaded) {
            final settings = state.settings;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Control general
                  GeneralSection(
                    allNotifications: settings.allNotifications,
                    systemPermissionGranted: true, // Assuming granted for UI simplicity or use permission_handler
                    onPermissionGranted: (_) {},
                    onChanged: (value) {
                       final newSettings = _updateAll(settings, value);
                       context.read<NotificationSettingsCubit>().updateSettings(newSettings);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tipos de notificaciones
                  NotificationTypesSection(
                    enabled: settings.allNotifications,
                    orderUpdates: settings.orderUpdates,
                    promotions: settings.promotions,
                    newProducts: settings.newProducts,
                    deliveryReminders: settings.deliveryReminders,
                    chatMessages: settings.chatMessages,
                    weeklyOffers: settings.weeklyOffers,
                    appUpdates: settings.appUpdates,
                    onOrderUpdatesChanged: (v) => _update(context, settings.copyWith(orderUpdates: v)),
                    onPromotionsChanged: (v) => _update(context, settings.copyWith(promotions: v)),
                    onNewProductsChanged: (v) => _update(context, settings.copyWith(newProducts: v)),
                    onDeliveryRemindersChanged: (v) => _update(context, settings.copyWith(deliveryReminders: v)),
                    onChatMessagesChanged: (v) => _update(context, settings.copyWith(chatMessages: v)),
                    onWeeklyOffersChanged: (v) => _update(context, settings.copyWith(weeklyOffers: v)),
                    onAppUpdatesChanged: (v) => _update(context, settings.copyWith(appUpdates: v)),
                  ),
                  const SizedBox(height: 24),

                  // Configuración de sonido
                  SoundSection(
                    enabled: settings.allNotifications,
                    soundEnabled: settings.soundEnabled,
                    vibrationEnabled: settings.vibrationEnabled,
                    soundType: settings.soundType,
                    onSoundEnabledChanged: (v) => _update(context, settings.copyWith(soundEnabled: v)),
                    onVibrationEnabledChanged: (v) => _update(context, settings.copyWith(vibrationEnabled: v)),
                    onSoundTypeChanged: (v) => _update(context, settings.copyWith(soundType: v)),
                  ),
                  const SizedBox(height: 24),

                  // Horarios de no molestar
                  QuietHoursSection(
                    enabled: settings.allNotifications,
                    quietHoursEnabled: settings.quietHoursEnabled,
                    startTime: TimeOfDay(hour: settings.quietHoursStartHour, minute: settings.quietHoursStartMinute),
                    endTime: TimeOfDay(hour: settings.quietHoursEndHour, minute: settings.quietHoursEndMinute),
                    onQuietHoursChanged: (v) => _update(context, settings.copyWith(quietHoursEnabled: v)),
                    onStartTimeChanged: (v) => _update(context, settings.copyWith(quietHoursStartHour: v.hour, quietHoursStartMinute: v.minute)),
                    onEndTimeChanged: (v) => _update(context, settings.copyWith(quietHoursEndHour: v.hour, quietHoursEndMinute: v.minute)),
                  ),
                  const SizedBox(height: 24),

                  // Información adicional
                  _buildInfoSection(context, theme),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _update(BuildContext context, NotificationSettings settings) {
    context.read<NotificationSettingsCubit>().updateSettings(settings);
  }

  NotificationSettings _updateAll(NotificationSettings current, bool enabled) {
    // Helper to toggle all
    return NotificationSettings(
      allNotifications: enabled,
      orderUpdates: enabled,
      promotions: enabled,
      newProducts: enabled,
      deliveryReminders: enabled,
      chatMessages: enabled,
      weeklyOffers: enabled,
      appUpdates: enabled,
      soundEnabled: current.soundEnabled,
      vibrationEnabled: current.vibrationEnabled,
      soundType: current.soundType,
      quietHoursEnabled: current.quietHoursEnabled,
      quietHoursStartHour: current.quietHoursStartHour,
      quietHoursStartMinute: current.quietHoursStartMinute,
      quietHoursEndHour: current.quietHoursEndHour,
      quietHoursEndMinute: current.quietHoursEndMinute,
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(
          (0.3 * 255).round(),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.importantNotificationsInfo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.8 * 255).round(),
                ),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension NotificationSettingsCopyWith on NotificationSettings {
  NotificationSettings copyWith({
    bool? allNotifications,
    bool? orderUpdates,
    bool? promotions,
    bool? newProducts,
    bool? deliveryReminders,
    bool? chatMessages,
    bool? weeklyOffers,
    bool? appUpdates,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? soundType,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
  }) {
    return NotificationSettings(
      allNotifications: allNotifications ?? this.allNotifications,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      newProducts: newProducts ?? this.newProducts,
      deliveryReminders: deliveryReminders ?? this.deliveryReminders,
      chatMessages: chatMessages ?? this.chatMessages,
      weeklyOffers: weeklyOffers ?? this.weeklyOffers,
      appUpdates: appUpdates ?? this.appUpdates,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundType: soundType ?? this.soundType,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursStartMinute: quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
    );
  }
}

