import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool allNotifications;
  final bool orderUpdates;
  final bool promotions;
  final bool newProducts;
  final bool deliveryReminders;
  final bool chatMessages;
  final bool weeklyOffers;
  final bool appUpdates;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String soundType;
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursStartMinute;
  final int quietHoursEndHour;
  final int quietHoursEndMinute;

  const NotificationSettings({
    this.allNotifications = true,
    this.orderUpdates = true,
    this.promotions = true,
    this.newProducts = true,
    this.deliveryReminders = true,
    this.chatMessages = true,
    this.weeklyOffers = true,
    this.appUpdates = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.soundType = 'default',
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursStartMinute = 0,
    this.quietHoursEndHour = 8,
    this.quietHoursEndMinute = 0,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    // Parse quiet hours time
    final startParts =
        (json['quiet_hours_start'] as String?)?.split(':') ?? ['22', '00'];
    final endParts =
        (json['quiet_hours_end'] as String?)?.split(':') ?? ['08', '00'];

    return NotificationSettings(
      allNotifications: json['all_notifications'] ?? true,
      orderUpdates: json['order_updates'] ?? true,
      promotions: json['promotions'] ?? true,
      newProducts: json['new_products'] ?? true,
      deliveryReminders: json['delivery_reminders'] ?? true,
      chatMessages: json['chat_messages'] ?? true,
      weeklyOffers: json['weekly_offers'] ?? true,
      appUpdates: json['app_updates'] ?? true,
      soundEnabled: json['sound_enabled'] ?? true,
      vibrationEnabled: json['vibration_enabled'] ?? true,
      soundType: json['sound_type'] ?? 'default',
      quietHoursEnabled: json['quiet_hours_enabled'] ?? false,
      quietHoursStartHour: int.tryParse(startParts[0]) ?? 22,
      quietHoursStartMinute: int.tryParse(startParts[1]) ?? 0,
      quietHoursEndHour: int.tryParse(endParts[0]) ?? 8,
      quietHoursEndMinute: int.tryParse(endParts[1]) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'all_notifications': allNotifications,
      'order_updates': orderUpdates,
      'promotions': promotions,
      'new_products': newProducts,
      'delivery_reminders': deliveryReminders,
      'chat_messages': chatMessages,
      'weekly_offers': weeklyOffers,
      'app_updates': appUpdates,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'sound_type': soundType,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start':
          '${quietHoursStartHour.toString().padLeft(2, '0')}:${quietHoursStartMinute.toString().padLeft(2, '0')}:00',
      'quiet_hours_end':
          '${quietHoursEndHour.toString().padLeft(2, '0')}:${quietHoursEndMinute.toString().padLeft(2, '0')}:00',
    };
  }

  @override
  List<Object?> get props => [
    allNotifications,
    orderUpdates,
    promotions,
    newProducts,
    deliveryReminders,
    chatMessages,
    weeklyOffers,
    appUpdates,
    soundEnabled,
    vibrationEnabled,
    soundType,
    quietHoursEnabled,
    quietHoursStartHour,
    quietHoursStartMinute,
    quietHoursEndHour,
    quietHoursEndMinute,
  ];
}
