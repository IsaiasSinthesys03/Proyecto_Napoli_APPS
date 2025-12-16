import 'package:injectable/injectable.dart';
import '../models/coupon_model.dart';

/// Local data source for coupons (offline fallback only, no mock data)
abstract class CouponLocalDataSource {
  Future<CouponModel?> getCoupon(String code);
}

/// Local cache implementation - coupons are fetched from Supabase exclusively
@LazySingleton(as: CouponLocalDataSource)
class CouponLocalDataSourceImpl implements CouponLocalDataSource {
  @override
  Future<CouponModel?> getCoupon(String code) async {
    // No local mock data - coupons come from Supabase only
    return null;
  }
}
