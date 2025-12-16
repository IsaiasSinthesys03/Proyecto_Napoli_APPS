import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/notification_settings.dart';

abstract class NotificationSettingsRepository {
  Future<NotificationSettings> getSettings(String customerId);
  Future<void> saveSettings(String customerId, NotificationSettings settings);
}

@LazySingleton(as: NotificationSettingsRepository)
class SupabaseNotificationSettingsRepository
    implements NotificationSettingsRepository {
  final RestaurantConfigService _configService;

  SupabaseNotificationSettingsRepository(this._configService);

  @override
  Future<NotificationSettings> getSettings(String customerId) async {
    final client = SupabaseConfig.client;

    final data = await client
        .from('customer_notification_preferences')
        .select()
        .eq('customer_id', customerId)
        .eq('restaurant_id', _configService.restaurantId)
        .limit(1)
        .maybeSingle();

    if (data == null) {
      // Return default settings if not found
      return const NotificationSettings();
    }

    return NotificationSettings.fromJson(data);
  }

  @override
  Future<void> saveSettings(
    String customerId,
    NotificationSettings settings,
  ) async {
    final client = SupabaseConfig.client;

    final data = settings.toJson();
    data['customer_id'] = customerId;
    data['restaurant_id'] = _configService.restaurantId;

    // Use upsert to handle both create and update
    await client
        .from('customer_notification_preferences')
        .upsert(data, onConflict: 'customer_id, restaurant_id');
  }
}
