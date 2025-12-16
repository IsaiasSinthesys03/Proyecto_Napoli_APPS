// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  categoryId: json['category_id'] as String?,
  priceCents: (json['price_cents'] as num).toInt(),
  imageUrl: json['image_url'] as String?,
  description: json['description'] as String? ?? '',
  availableExtras:
      (json['availableExtras'] as List<dynamic>?)
          ?.map((e) => ProductExtraModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isAvailable: json['is_available'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
);

Map<String, dynamic> _$ProductModelToJson(
  ProductModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'category_id': instance.categoryId,
  'price_cents': instance.priceCents,
  'image_url': instance.imageUrl,
  'description': instance.description,
  'availableExtras': instance.availableExtras.map((e) => e.toJson()).toList(),
  'is_available': instance.isAvailable,
  'is_featured': instance.isFeatured,
};

ProductExtraModel _$ProductExtraModelFromJson(Map<String, dynamic> json) =>
    ProductExtraModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$ProductExtraModelToJson(ProductExtraModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
    };
