import 'package:injectable/injectable.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/restaurant_config_service.dart';
import '../models/coupon_model.dart';

/// Remote data source for coupons using Supabase
abstract class CouponRemoteDataSource {
  Future<CouponModel?> getCoupon(String code);
  Future<void> useCoupon(String customerId, String couponId, String? orderId);
}

/// Supabase implementation of CouponRemoteDataSource
@LazySingleton(as: CouponRemoteDataSource)
class SupabaseCouponDataSource implements CouponRemoteDataSource {
  final RestaurantConfigService _configService;

  SupabaseCouponDataSource(this._configService);

  @override
  Future<CouponModel?> getCoupon(String code) async {
    final client = SupabaseConfig.client;
    final normalizedCode = code.trim().toUpperCase();

    // Query coupons table for valid coupon
    final data = await client
        .from('coupons')
        .select()
        .eq('restaurant_id', _configService.restaurantId)
        .eq('code', normalizedCode)
        .eq('is_active', true)
        .maybeSingle();

    if (data == null) return null;

    // Check validity dates
    final now = DateTime.now();
    final validFrom = data['valid_from'] != null
        ? DateTime.parse(data['valid_from'] as String)
        : null;
    final validUntil = data['valid_until'] != null
        ? DateTime.parse(data['valid_until'] as String)
        : null;

    if (validFrom != null && now.isBefore(validFrom)) return null;
    if (validUntil != null && now.isAfter(validUntil)) return null;

    // Check usage limits
    final maxUses = data['max_uses'] as int?;
    final currentUses = data['current_uses'] as int? ?? 0;
    if (maxUses != null && currentUses >= maxUses) return null;

    return CouponModel.fromSupabase(data);
  }

  @override
  Future<void> useCoupon(
    String customerId,
    String couponId,
    String? orderId,
  ) async {
    final client = SupabaseConfig.client;

    // Insert into customer_coupons
    await client.from('customer_coupons').insert({
      'customer_id': customerId,
      'coupon_id': couponId,
      'restaurant_id': _configService.restaurantId,
      'used_at': DateTime.now().toIso8601String(),
      'order_id': orderId,
    });

    // Increment current_uses on the coupon
    await client.rpc('increment_coupon_usage', params: {'coupon_id': couponId});
  }
}
