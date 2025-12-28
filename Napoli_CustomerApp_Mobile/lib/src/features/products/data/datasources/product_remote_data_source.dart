import 'package:injectable/injectable.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../core/network/supabase_logger.dart';
import '../../../../core/services/restaurant_config_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

/// Remote data source for products using Supabase
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel?> getProductById(String id);
}

/// Supabase implementation of ProductRemoteDataSource
@LazySingleton(as: ProductRemoteDataSource)
class SupabaseProductDataSource implements ProductRemoteDataSource {
  final RestaurantConfigService _configService;

  SupabaseProductDataSource(this._configService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    print('🔍 DEBUG - Starting getCategories');

    final client = SupabaseConfig.client;

    try {
      print('🔍 DEBUG - Calling get_categories stored procedure');
      print('📦 DATA - restaurant_id: ${_configService.restaurantId}');

      final response = await client.rpc(
        'get_categories',
        params: {'p_restaurant_id': _configService.restaurantId},
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('📦 DATA - No categories found, returning empty list');
        return [];
      }

      final categoriesData = response as List;
      print('📦 DATA - Parsing ${categoriesData.length} categories');

      final categories = categoriesData
          .map((cat) => CategoryModel.fromJson(cat as Map<String, dynamic>))
          .toList();

      print('✅ SUCCESS - Categories parsed successfully');
      return categories;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getCategories: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      SupabaseLogger.logError('get_categories', 'RPC', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    print('🔍 DEBUG - Starting getProducts');

    final client = SupabaseConfig.client;

    try {
      print('🔍 DEBUG - Calling get_menu_items stored procedure');
      print('📦 DATA - restaurant_id: ${_configService.restaurantId}');

      final response = await client.rpc(
        'get_menu_items',
        params: {'p_restaurant_id': _configService.restaurantId},
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('📦 DATA - No products found, returning empty list');
        return [];
      }

      final productsData = response as List;
      print('📦 DATA - Parsing ${productsData.length} products');

      final products = productsData.map((productJson) {
        final product = productJson as Map<String, dynamic>;

        // Extract addons from the response
        final addonsJson =
            (product['addons'] as List?)
                ?.map((addon) => addon as Map<String, dynamic>)
                .toList() ??
            [];

        return ProductModel.fromSupabase(product, addonsJson);
      }).toList();

      print('✅ SUCCESS - Products parsed successfully');
      print('📦 DATA - Total products: ${products.length}');

      return products;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getProducts: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      SupabaseLogger.logError('get_menu_items', 'RPC', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    print('🔍 DEBUG - Starting getProductById for id: $id');

    final client = SupabaseConfig.client;

    try {
      print('🔍 DEBUG - Calling get_product_details stored procedure');

      final response = await client.rpc(
        'get_product_details',
        params: {'p_product_id': id},
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('📦 DATA - Product not found');
        return null;
      }

      final productData = response as Map<String, dynamic>;
      print('📦 DATA - Parsing product details');

      // Extract addons from the response
      final addonsJson =
          (productData['addons'] as List?)
              ?.map((addon) => addon as Map<String, dynamic>)
              .toList() ??
          [];

      final product = ProductModel.fromSupabase(productData, addonsJson);

      print('✅ SUCCESS - Product details parsed successfully');
      print('📦 DATA - Product: ${product.name}');

      return product;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getProductById: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      SupabaseLogger.logError('get_product_details', 'RPC', e);
      rethrow;
    }
  }
}
