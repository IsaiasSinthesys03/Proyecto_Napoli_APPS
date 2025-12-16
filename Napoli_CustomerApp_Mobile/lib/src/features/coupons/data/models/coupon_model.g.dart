// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponModel _$CouponModelFromJson(Map<String, dynamic> json) => CouponModel(
  code: json['code'] as String,
  discountPercentage: (json['discountPercentage'] as num).toInt(),
  description: json['description'] as String,
  discountAmountCents: (json['discount_amount_cents'] as num?)?.toInt(),
  minimumOrderCents: (json['minimum_order_cents'] as num?)?.toInt(),
  maximumDiscountCents: (json['maximum_discount_cents'] as num?)?.toInt(),
  type: json['type'] as String?,
);

Map<String, dynamic> _$CouponModelToJson(CouponModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'discountPercentage': instance.discountPercentage,
      'description': instance.description,
      'discount_amount_cents': instance.discountAmountCents,
      'minimum_order_cents': instance.minimumOrderCents,
      'maximum_discount_cents': instance.maximumDiscountCents,
      'type': instance.type,
    };
