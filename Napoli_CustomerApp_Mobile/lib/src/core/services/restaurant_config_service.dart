import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';

/// Service for fetching restaurant configuration from Supabase.
/// This is the SINGLE SOURCE OF TRUTH for restaurant_id across the app.
@LazySingleton()
class RestaurantConfigService {
  /// The restaurant ID this app is configured for.
  /// In production, this could come from app config, deep link, or environment.
  static const String _defaultRestaurantId =
      '06a5284c-0ef8-4efe-a882-ce1fc8319452';

  Map<String, dynamic>? _cachedConfig;

  /// Get the restaurant ID (single source of truth)
  String get restaurantId => _defaultRestaurantId;

  /// Get currency symbol synchronously (uses cache, defaults to '$')
  String get currencySymbol =>
      _cachedConfig?['currency_symbol'] as String? ?? '\$';

  /// Get currency code synchronously (uses cache, defaults to 'MXN')
  String get currencyCode =>
      _cachedConfig?['currency_code'] as String? ?? 'MXN';

  /// Format price synchronously using cached config
  /// [price] is the price in whole units (not cents)
  String formatPriceSync(num price) {
    return '$currencySymbol${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)} $currencyCode';
  }

  /// Get restaurant configuration (cached)
  Future<Map<String, dynamic>> getConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;

    final client = SupabaseConfig.client;

    final data = await client
        .from('restaurants')
        .select()
        .eq('id', restaurantId)
        .limit(1)
        .maybeSingle();

    if (data == null) {
      // Fallback or throw explicit error
      throw Exception('Restaurante no encontrado (ID: $restaurantId)');
    }

    _cachedConfig = data;
    return data;
  }

  /// Get currency symbol
  Future<String> getCurrencySymbol() async {
    final config = await getConfig();
    return config['currency_symbol'] as String? ?? '\$';
  }

  /// Get currency code
  Future<String> getCurrencyCode() async {
    final config = await getConfig();
    return config['currency_code'] as String? ?? 'MXN';
  }

  /// Get minimum order amount in cents
  Future<int> getMinimumOrderCents() async {
    final config = await getConfig();
    return config['minimum_order_cents'] as int? ?? 0;
  }

  /// Get delivery fee in cents
  Future<int> getDeliveryFeeCents() async {
    final config = await getConfig();
    return config['delivery_fee_cents'] as int? ?? 0;
  }

  /// Get free delivery threshold in cents
  Future<int> getFreeDeliveryThresholdCents() async {
    final config = await getConfig();
    return config['free_delivery_threshold_cents'] as int? ?? 0;
  }

  /// Get restaurant name
  Future<String> getRestaurantName() async {
    final config = await getConfig();
    return config['name'] as String? ?? 'Restaurant';
  }

  /// Get restaurant location info
  Future<Map<String, dynamic>> getRestaurantLocation() async {
    final config = await getConfig();
    return {
      'address': config['address'] as String? ?? '',
      'city': config['city'] as String? ?? '',
      'lat': config['latitude'] as double? ?? 0.0,
      'lng': config['longitude'] as double? ?? 0.0,
    };
  }

  /// Check if restaurant accepts delivery
  Future<bool> acceptsDelivery() async {
    final config = await getConfig();
    return config['accepts_delivery'] as bool? ?? true;
  }

  /// Check if restaurant accepts pickup
  Future<bool> acceptsPickup() async {
    final config = await getConfig();
    return config['accepts_pickup'] as bool? ?? true;
  }

  /// Check if restaurant is currently open
  Future<bool> isOpen() async {
    final config = await getConfig();
    return config['is_open'] as bool? ?? true;
  }

  /// Format price from cents to display string
  Future<String> formatPrice(int cents) async {
    final symbol = await getCurrencySymbol();
    final decimals = cents % 100 == 0 ? 0 : 2;
    final amount = cents / 100;
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// Get business hours configuration
  Future<Map<String, dynamic>> getBusinessHours() async {
    final config = await getConfig();
    return config['business_hours'] as Map<String, dynamic>? ?? {};
  }

  /// Get bank details for transfers
  Future<Map<String, String>> getBankDetails() async {
    final config = await getConfig();
    return {
      'banco': config['bank_name'] as String? ?? '',
      'titular': config['bank_account_name'] as String? ?? 'PIZZERIA NAPOLI',
      'clabe': config['bank_account_clabe'] as String? ?? '',
      // 'cuenta' is not in schema explicitly, usually derived or in clabe, but we'll leave empty or map to clabe
      'cuenta':
          config['bank_account_clabe'] as String? ?? '', // Fallback to CLABE
    };
  }

  /// Clear cached config (for refresh)
  void clearCache() {
    _cachedConfig = null;
  }
}
