// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  photoUrl: json['photoUrl'] as String?,
  savedAddresses:
      (json['savedAddresses'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  savedCards:
      (json['savedCards'] as List<dynamic>?)
          ?.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
  loyaltyTier: json['loyaltyTier'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'photoUrl': instance.photoUrl,
  'savedAddresses': instance.savedAddresses,
  'savedCards': instance.savedCards,
  'loyaltyPoints': instance.loyaltyPoints,
  'loyaltyTier': instance.loyaltyTier,
};
