import 'package:json_annotation/json_annotation.dart';
import '../../../../core/core_domain/entities/category.dart';

part 'category_model.g.dart';

/// Model for product categories from the database
@JsonSerializable()
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      displayOrder: displayOrder,
      isActive: isActive,
    );
  }
}
