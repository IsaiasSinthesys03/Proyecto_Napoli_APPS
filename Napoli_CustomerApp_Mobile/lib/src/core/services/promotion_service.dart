import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'restaurant_config_service.dart';

/// Model for a promotion from the database
class Promotion {
  final String id;
  final String name;
  final String? description;
  final String type;
  final int? discountPercentage;
  final int? discountAmountCents;
  final int minimumOrderCents;
  final int? maximumDiscountCents;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String? bannerUrl;
  final bool isActive;
  final bool isFeatured;

  Promotion({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.discountPercentage,
    this.discountAmountCents,
    required this.minimumOrderCents,
    this.maximumDiscountCents,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.bannerUrl,
    required this.isActive,
    required this.isFeatured,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      discountPercentage: json['discount_percentage'] as int?,
      discountAmountCents: json['discount_amount_cents'] as int?,
      minimumOrderCents: json['minimum_order_cents'] as int? ?? 0,
      maximumDiscountCents: json['maximum_discount_cents'] as int?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      imageUrl: json['image_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  /// Returns a user-friendly description of the discount
  String get discountDescription {
    if (discountPercentage != null && discountPercentage! > 0) {
      return '$discountPercentage% de descuento';
    } else if (discountAmountCents != null && discountAmountCents! > 0) {
      final amount = discountAmountCents! / 100;
      return '\$${amount.toStringAsFixed(0)} de descuento';
    }
    return description ?? name;
  }
}

/// Service to fetch promotions from Supabase
@lazySingleton
class PromotionService {
  final RestaurantConfigService _configService;

  PromotionService(this._configService);

  /// Fetches active promotions for the current restaurant
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final supabase = Supabase.instance.client;
      final restaurantId = _configService.restaurantId;
      final now = DateTime.now().toUtc().toIso8601String();

      final response = await supabase
          .from('promotions')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_active', true)
          .lte('start_date', now)
          .gte('end_date', now)
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Promotion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error - don't crash the app
      return [];
    }
  }

  /// Gets a single featured promotion for the home banner
  Future<Promotion?> getFeaturedPromotion() async {
    final promotions = await getActivePromotions();
    if (promotions.isEmpty) return null;

    // Prefer featured promotions
    final featured = promotions.where((p) => p.isFeatured).toList();
    if (featured.isNotEmpty) return featured.first;

    // Otherwise return the most recent
    return promotions.first;
  }
}
