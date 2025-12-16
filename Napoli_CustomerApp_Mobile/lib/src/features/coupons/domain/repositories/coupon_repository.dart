import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/coupon.dart';

abstract class CouponRepository {
  Future<void> saveCoupon(String couponCode);
  Future<Either<Failure, List<Coupon>>> getCoupons();
  Future<Either<Failure, Coupon?>> getCoupon(String code);
  Future<void> clearHistory();
  Future<int> getCouponCount();
}
