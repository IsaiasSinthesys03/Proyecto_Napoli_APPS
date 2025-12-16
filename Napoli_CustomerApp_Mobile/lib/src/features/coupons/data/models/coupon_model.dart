import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/coupon.dart';

part 'coupon_model.g.dart';

@JsonSerializable()
class CouponModel extends Coupon {
  @JsonKey(name: 'discount_amount_cents')
  final int? discountAmountCents;
  @JsonKey(name: 'minimum_order_cents')
  final int? minimumOrderCents;
  @JsonKey(name: 'maximum_discount_cents')
  final int? maximumDiscountCents;
  final String? type; // 'percentage' or 'fixed'

  const CouponModel({
    required super.code,
    required super.discountPercentage,
    required super.description,
    this.discountAmountCents,
    this.minimumOrderCents,
    this.maximumDiscountCents,
    this.type,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) =>
      _$CouponModelFromJson(json);

  Map<String, dynamic> toJson() => _$CouponModelToJson(this);

  /// Factory to create from Supabase coupons table
  factory CouponModel.fromSupabase(Map<String, dynamic> data) {
    return CouponModel(
      code: data['code'] as String,
      discountPercentage: data['discount_percentage'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      discountAmountCents: data['discount_amount_cents'] as int?,
      minimumOrderCents: data['minimum_order_cents'] as int?,
      maximumDiscountCents: data['maximum_discount_cents'] as int?,
      type: data['type'] as String?,
    );
  }

  factory CouponModel.fromEntity(Coupon coupon) {
    return CouponModel(
      code: coupon.code,
      discountPercentage: coupon.discountPercentage,
      description: coupon.description,
    );
  }
}
