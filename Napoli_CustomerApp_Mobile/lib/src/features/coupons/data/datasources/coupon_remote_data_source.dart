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
    print('🔍 DEBUG - Starting getCoupon for code: $code');

    final client = SupabaseConfig.client;

    try {
      // Get current user for customer_id
      final currentUser = client.auth.currentUser;
      String? customerId;

      if (currentUser != null) {
        // Get customer_id from email
        final customerData = await client
            .from('customers')
            .select('id')
            .eq('email', currentUser.email!)
            .eq('restaurant_id', _configService.restaurantId)
            .maybeSingle();

        customerId = customerData?['id'] as String?;
      }

      print('🔍 DEBUG - Calling validate_coupon stored procedure');
      print('📦 DATA - code: $code, customer_id: $customerId');

      final response = await client.rpc(
        'validate_coupon',
        params: {
          'p_code': code,
          'p_restaurant_id': _configService.restaurantId,
          'p_customer_id': customerId,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('📦 DATA - Coupon not valid or not found');
        return null;
      }

      final couponData = response as Map<String, dynamic>;
      print('📦 DATA - Parsing coupon: ${couponData['code']}');

      final coupon = CouponModel.fromSupabase(couponData);

      print('✅ SUCCESS - Coupon validated successfully');
      return coupon;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getCoupon: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> useCoupon(
    String customerId,
    String couponId,
    String? orderId,
  ) async {
    print('🔍 DEBUG - Starting useCoupon');
    print('📦 DATA - customer_id: $customerId, coupon_id: $couponId');

    final client = SupabaseConfig.client;

    try {
      print('🔍 DEBUG - Calling use_coupon stored procedure');

      final response = await client.rpc(
        'use_coupon',
        params: {
          'p_customer_id': customerId,
          'p_coupon_id': couponId,
          'p_restaurant_id': _configService.restaurantId,
          'p_order_id': orderId,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response: $response');
      print('✅ SUCCESS - Coupon used successfully');
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in useCoupon: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }
}
