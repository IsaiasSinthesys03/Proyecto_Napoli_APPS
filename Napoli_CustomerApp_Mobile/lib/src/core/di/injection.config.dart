// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/update_profile_usecase.dart'
    as _i798;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/cart/data/datasources/cart_local_data_source.dart'
    as _i706;
import '../../features/cart/data/repositories/cart_repository_impl.dart'
    as _i642;
import '../../features/cart/domain/repositories/cart_repository.dart' as _i322;
import '../../features/cart/domain/usecases/clear_cart_usecase.dart' as _i240;
import '../../features/cart/domain/usecases/get_cart_usecase.dart' as _i179;
import '../../features/cart/domain/usecases/save_cart_usecase.dart' as _i903;
import '../../features/cart/presentation/cubit/cart_cubit.dart' as _i499;
import '../../features/coupons/data/datasources/coupon_local_data_source.dart'
    as _i63;
import '../../features/coupons/data/datasources/coupon_remote_data_source.dart'
    as _i419;
import '../../features/coupons/data/repositories/coupon_repository_impl.dart'
    as _i346;
import '../../features/coupons/domain/repositories/coupon_repository.dart'
    as _i664;
import '../../features/coupons/domain/usecases/get_coupon_usecase.dart'
    as _i621;
import '../../features/home/presentation/cubit/business_status_cubit.dart'
    as _i821;
import '../../features/orders/data/datasources/order_local_data_source.dart'
    as _i85;
import '../../features/orders/data/datasources/order_remote_data_source.dart'
    as _i1011;
import '../../features/orders/data/repositories/order_repository_impl.dart'
    as _i376;
import '../../features/orders/domain/repositories/order_repository.dart'
    as _i543;
import '../../features/orders/domain/usecases/get_orders_usecase.dart' as _i755;
import '../../features/orders/domain/usecases/save_order_usecase.dart' as _i56;
import '../../features/orders/presentation/cubit/orders_cubit.dart' as _i1028;
import '../../features/products/data/datasources/product_remote_data_source.dart'
    as _i166;
import '../../features/products/data/repositories/product_repository_impl.dart'
    as _i764;
import '../../features/products/domain/usecases/get_business_lunch_usecase.dart'
    as _i887;
import '../../features/products/domain/usecases/get_categories_usecase.dart'
    as _i583;
import '../../features/products/domain/usecases/get_product_detail_usecase.dart'
    as _i639;
import '../../features/products/domain/usecases/get_products_usecase.dart'
    as _i15;
import '../../features/products/presentation/cubit/product_detail_cubit.dart'
    as _i582;
import '../../features/products/presentation/cubit/products_cubit.dart'
    as _i911;
import '../../features/settings/data/repositories/notification_settings_repository.dart'
    as _i496;
import '../../features/settings/data/repositories/order_history_repository_impl.dart'
    as _i582;
import '../../features/settings/domain/repositories/order_history_repository.dart'
    as _i901;
import '../../features/settings/presentation/cubit/notification_settings_cubit.dart'
    as _i464;
import '../core_domain/repositories/product_repository.dart' as _i1009;
import '../network/dio_client.dart' as _i667;
import '../network/network_module.dart' as _i200;
import '../services/business_hours.service.dart' as _i448;
import '../services/local_storage_service.dart' as _i527;
import '../services/promotion_service.dart' as _i941;
import '../services/restaurant_config_service.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i809.RestaurantConfigService>(
      () => _i809.RestaurantConfigService(),
    );
    gh.lazySingleton<_i901.OrderHistoryRepository>(
      () => _i582.SupabaseOrderHistoryRepository(
        gh<_i809.RestaurantConfigService>(),
      ),
    );
    gh.lazySingleton<_i419.CouponRemoteDataSource>(
      () => _i419.SupabaseCouponDataSource(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.SupabaseAuthDataSource(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i63.CouponLocalDataSource>(
      () => _i63.CouponLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i1011.OrderRemoteDataSource>(
      () => _i1011.SupabaseOrderDataSource(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i527.LocalStorageService>(
      () => _i527.LocalStorageServiceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i667.DioClient>(() => _i667.DioClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i448.BusinessHoursService>(
      () => _i448.BusinessHoursService(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i941.PromotionService>(
      () => _i941.PromotionService(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i706.CartLocalDataSource>(
      () => _i706.CartLocalDataSourceImpl(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i85.OrderLocalDataSource>(
      () => _i85.OrderLocalDataSourceImpl(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i496.NotificationSettingsRepository>(
      () => _i496.SupabaseNotificationSettingsRepository(
        gh<_i809.RestaurantConfigService>(),
      ),
    );
    gh.lazySingleton<_i322.CartRepository>(
      () => _i642.CartRepositoryImpl(gh<_i706.CartLocalDataSource>()),
    );
    gh.lazySingleton<_i166.ProductRemoteDataSource>(
      () =>
          _i166.SupabaseProductDataSource(gh<_i809.RestaurantConfigService>()),
    );
    gh.lazySingleton<_i240.ClearCartUseCase>(
      () => _i240.ClearCartUseCase(gh<_i322.CartRepository>()),
    );
    gh.lazySingleton<_i179.GetCartUseCase>(
      () => _i179.GetCartUseCase(gh<_i322.CartRepository>()),
    );
    gh.lazySingleton<_i903.SaveCartUseCase>(
      () => _i903.SaveCartUseCase(gh<_i322.CartRepository>()),
    );
    gh.factory<_i821.BusinessStatusCubit>(
      () => _i821.BusinessStatusCubit(gh<_i448.BusinessHoursService>()),
    );
    gh.lazySingleton<_i543.OrderRepository>(
      () => _i376.OrderRepositoryImpl(
        gh<_i85.OrderLocalDataSource>(),
        gh<_i1011.OrderRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i664.CouponRepository>(
      () => _i346.CouponRepositoryImpl(
        gh<_i419.CouponRemoteDataSource>(),
        gh<_i809.RestaurantConfigService>(),
      ),
    );
    gh.lazySingleton<_i621.GetCouponUseCase>(
      () => _i621.GetCouponUseCase(gh<_i664.CouponRepository>()),
    );
    gh.lazySingleton<_i1009.ProductRepository>(
      () => _i764.ProductRepositoryImpl(gh<_i166.ProductRemoteDataSource>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i527.LocalStorageService>(),
        gh<_i107.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i499.CartCubit>(
      () => _i499.CartCubit(
        gh<_i179.GetCartUseCase>(),
        gh<_i903.SaveCartUseCase>(),
        gh<_i240.ClearCartUseCase>(),
        gh<_i621.GetCouponUseCase>(),
      ),
    );
    gh.lazySingleton<_i755.GetOrdersUseCase>(
      () => _i755.GetOrdersUseCase(gh<_i543.OrderRepository>()),
    );
    gh.lazySingleton<_i56.SaveOrderUseCase>(
      () => _i56.SaveOrderUseCase(gh<_i543.OrderRepository>()),
    );
    gh.lazySingleton<_i887.GetBusinessLunchUseCase>(
      () => _i887.GetBusinessLunchUseCase(gh<_i1009.ProductRepository>()),
    );
    gh.lazySingleton<_i583.GetCategoriesUseCase>(
      () => _i583.GetCategoriesUseCase(gh<_i1009.ProductRepository>()),
    );
    gh.lazySingleton<_i639.GetProductDetailUseCase>(
      () => _i639.GetProductDetailUseCase(gh<_i1009.ProductRepository>()),
    );
    gh.lazySingleton<_i15.GetProductsUseCase>(
      () => _i15.GetProductsUseCase(gh<_i1009.ProductRepository>()),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i798.UpdateProfileUseCase>(
      () => _i798.UpdateProfileUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i911.ProductsCubit>(
      () => _i911.ProductsCubit(
        gh<_i15.GetProductsUseCase>(),
        gh<_i639.GetProductDetailUseCase>(),
        gh<_i887.GetBusinessLunchUseCase>(),
        gh<_i583.GetCategoriesUseCase>(),
      ),
    );
    gh.factory<_i1028.OrdersCubit>(
      () => _i1028.OrdersCubit(
        gh<_i56.SaveOrderUseCase>(),
        gh<_i755.GetOrdersUseCase>(),
      ),
    );
    gh.factory<_i582.ProductDetailCubit>(
      () => _i582.ProductDetailCubit(gh<_i639.GetProductDetailUseCase>()),
    );
    gh.lazySingleton<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i17.GetCurrentUserUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i798.UpdateProfileUseCase>(),
      ),
    );
    gh.factory<_i464.NotificationSettingsCubit>(
      () => _i464.NotificationSettingsCubit(
        gh<_i496.NotificationSettingsRepository>(),
        gh<_i117.AuthCubit>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i527.RegisterModule {}

class _$NetworkModule extends _i200.NetworkModule {}
