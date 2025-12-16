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
    final client = SupabaseConfig.client;

    SupabaseLogger.logQuery(
      'categories',
      'SELECT',
      filters: {
        'restaurant_id': _configService.restaurantId,
        'is_active': true,
      },
    );

    try {
      final data = await client
          .from('categories')
          .select()
          .eq('restaurant_id', _configService.restaurantId)
          .eq('is_active', true)
          .order('display_order');

      SupabaseLogger.logResponse('categories', data);
      return (data as List).map((cat) => CategoryModel.fromJson(cat)).toList();
    } catch (e) {
      SupabaseLogger.logError('categories', 'SELECT', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final client = SupabaseConfig.client;

    SupabaseLogger.logQuery(
      'products',
      'SELECT',
      select: '*, category:categories(id, name)',
      filters: {
        'restaurant_id': _configService.restaurantId,
        'is_available': true,
      },
    );

    try {
      // Fetch products with their category info
      final productsData = await client
          .from('products')
          .select('''
            *,
            category:categories(id, name)
          ''')
          .eq('restaurant_id', _configService.restaurantId)
          .eq('is_available', true)
          .order('display_order');

      SupabaseLogger.logResponse('products', productsData);

      // Fetch all product addons for this restaurant
      SupabaseLogger.logQuery(
        'product_addons',
        'SELECT',
        select: 'product_id, addon:addons!inner(*)',
      );

      final addonRelations = await client.from('product_addons').select('''
            product_id,
            addon:addons!inner(*)
          ''');

      SupabaseLogger.logResponse('product_addons', addonRelations);

      // Group addons by product_id
      final addonsByProduct = <String, List<Map<String, dynamic>>>{};
      for (final relation in addonRelations as List) {
        final productId = relation['product_id'] as String;
        final addon = relation['addon'] as Map<String, dynamic>;
        addonsByProduct.putIfAbsent(productId, () => []).add(addon);
      }

      return (productsData as List).map((product) {
        final productId = product['id'] as String;
        final productAddons = addonsByProduct[productId] ?? [];

        return ProductModel.fromSupabase(product, productAddons);
      }).toList();
    } catch (e) {
      SupabaseLogger.logError('products', 'SELECT', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    final client = SupabaseConfig.client;

    final productData = await client
        .from('products')
        .select('''
          *,
          category:categories(id, name)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (productData == null) return null;

    // Fetch addons for this product
    final addonRelations = await client
        .from('product_addons')
        .select('''
          addon:addons!inner(*)
        ''')
        .eq('product_id', id);

    final addons = (addonRelations as List)
        .map((r) => r['addon'] as Map<String, dynamic>)
        .toList();

    return ProductModel.fromSupabase(productData, addons);
  }
}
