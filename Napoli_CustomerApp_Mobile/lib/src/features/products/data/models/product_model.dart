import 'package:json_annotation/json_annotation.dart';
import '../../../../core/core_domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel {
  final String id;
  final String name;
  final String category;
  @JsonKey(name: 'category_id')
  final String? categoryId;

  /// Price in cents (divide by 100 for display)
  @JsonKey(name: 'price_cents')
  final int priceCents;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(defaultValue: [])
  final List<ProductExtraModel> availableExtras;
  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;
  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    this.categoryId,
    required this.priceCents,
    this.imageUrl,
    required this.description,
    required this.availableExtras,
    this.isAvailable = true,
    this.isFeatured = false,
  });

  /// Price in pesos (for display)
  double get price => priceCents / 100;

  /// Image path (supports URL or local asset)
  String get image => imageUrl ?? 'assets/image-products/pizza.png';

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Factory to create from Supabase response with addons
  factory ProductModel.fromSupabase(
    Map<String, dynamic> product,
    List<Map<String, dynamic>> addons,
  ) {
    final category = product['category'] as Map<String, dynamic>?;

    return ProductModel(
      id: product['id'] as String,
      name: product['name'] as String,
      category: category?['name'] as String? ?? 'Sin categoría',
      categoryId: product['category_id'] as String?,
      priceCents: product['price_cents'] as int? ?? 0,
      imageUrl: product['image_url'] as String?,
      description: product['description'] as String? ?? '',
      isAvailable: product['is_available'] as bool? ?? true,
      isFeatured: product['is_featured'] as bool? ?? false,
      availableExtras: addons
          .map((addon) => ProductExtraModel.fromSupabase(addon))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      category: category,
      price: priceCents, // Keep in cents internally
      image: image,
      description: description,
      availableExtras: availableExtras.map((e) => e.toEntity()).toList(),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      category: product.category,
      priceCents: product.price,
      imageUrl: product.image.startsWith('http') ? product.image : null,
      description: product.description,
      availableExtras: product.availableExtras
          .map((e) => ProductExtraModel.fromEntity(e))
          .toList(),
    );
  }
}

@JsonSerializable()
class ProductExtraModel extends ProductExtra {
  const ProductExtraModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ProductExtraModel.fromJson(Map<String, dynamic> json) =>
      _$ProductExtraModelFromJson(json);

  /// Factory to create from Supabase addons table response
  factory ProductExtraModel.fromSupabase(Map<String, dynamic> addon) {
    return ProductExtraModel(
      id: addon['id'] as String,
      name: addon['name'] as String,
      price: addon['price_cents'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$ProductExtraModelToJson(this);

  ProductExtra toEntity() {
    return ProductExtra(id: id, name: name, price: price);
  }

  factory ProductExtraModel.fromEntity(ProductExtra extra) {
    return ProductExtraModel(
      id: extra.id,
      name: extra.name,
      price: extra.price,
    );
  }
}
