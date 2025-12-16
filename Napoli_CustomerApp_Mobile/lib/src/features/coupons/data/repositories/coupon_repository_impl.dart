import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/restaurant_config_service.dart';
import '../../domain/entities/coupon.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../datasources/coupon_remote_data_source.dart';

/// Repository for coupon operations - fetches from Supabase customer_coupons table
@LazySingleton(as: CouponRepository)
class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource _remoteDataSource;
  final RestaurantConfigService _configService;

  CouponRepositoryImpl(this._remoteDataSource, this._configService);

  @override
  Future<void> saveCoupon(String couponCode) async {
    // Fetch coupon details from Supabase to validate
    final couponModel = await _remoteDataSource.getCoupon(couponCode);
    if (couponModel == null) return;

    // Get current user
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Get customer ID from customers table
    final customersResponse = await Supabase.instance.client
        .from('customers')
        .select('id')
        .eq('restaurant_id', _configService.restaurantId)
        .eq('email', user.email!)
        .maybeSingle();

    if (customersResponse == null) return;

    final customerId = customersResponse['id'] as String;

    // Record the coupon usage in customer_coupons
    await _remoteDataSource.useCoupon(customerId, couponModel.code, null);
  }

  @override
  Future<Either<Failure, List<Coupon>>> getCoupons() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        return const Right([]);
      }

      final restaurantId = _configService.restaurantId;

      // Get customer ID
      final customerResponse = await supabase
          .from('customers')
          .select('id')
          .eq('restaurant_id', restaurantId)
          .eq('email', user.email!)
          .maybeSingle();

      if (customerResponse == null) {
        return const Right([]);
      }

      final customerId = customerResponse['id'] as String;

      // Fetch used coupons with coupon details via join
      final response = await supabase
          .from('customer_coupons')
          .select('''
            id,
            used_at,
            created_at,
            coupon:coupons(
              id,
              code,
              description,
              type,
              discount_percentage,
              discount_amount_cents,
              minimum_order_cents,
              maximum_discount_cents
            )
          ''')
          .eq('customer_id', customerId)
          .eq('restaurant_id', restaurantId)
          .order('created_at', ascending: false);

      final coupons = (response as List).map((entry) {
        final couponData = entry['coupon'] as Map<String, dynamic>?;
        if (couponData == null) {
          return Coupon(
            code: 'UNKNOWN',
            discountPercentage: 0,
            description: 'Cupón no disponible',
            receivedDate: DateTime.now(),
          );
        }

        final usedAt = entry['used_at'] as String?;
        final createdAt = entry['created_at'] as String?;

        return Coupon(
          code: couponData['code'] as String? ?? 'UNKNOWN',
          discountPercentage: couponData['discount_percentage'] as int? ?? 0,
          description: couponData['description'] as String? ?? 'Cupón aplicado',
          receivedDate: usedAt != null
              ? DateTime.parse(usedAt)
              : (createdAt != null
                    ? DateTime.parse(createdAt)
                    : DateTime.now()),
        );
      }).toList();

      return Right(coupons);
    } catch (e) {
      return Left(ServerFailure('Error al cargar cupones: $e'));
    }
  }

  @override
  Future<Either<Failure, Coupon?>> getCoupon(String code) async {
    try {
      final couponModel = await _remoteDataSource.getCoupon(code);
      if (couponModel == null) {
        return const Right(null);
      }

      return Right(
        Coupon(
          code: couponModel.code,
          discountPercentage: couponModel.discountPercentage,
          description: couponModel.description,
          receivedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Error al buscar cupón: $e'));
    }
  }

  @override
  Future<void> clearHistory() async {
    // For now, we don't delete from Supabase - this is just historical data
    // In the future, could implement soft delete or admin-only deletion
  }

  @override
  Future<int> getCouponCount() async {
    final result = await getCoupons();
    return result.fold((failure) => 0, (coupons) => coupons.length);
  }
}
