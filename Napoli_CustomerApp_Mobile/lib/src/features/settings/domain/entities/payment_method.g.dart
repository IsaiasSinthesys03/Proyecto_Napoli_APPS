// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      type: $enumDecode(_$PaymentTypeEnumMap, json['type']),
      cardNumber: json['cardNumber'] as String?,
      cardHolder: json['cardHolder'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cardBrand: json['cardBrand'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$PaymentTypeEnumMap[instance.type]!,
      'cardNumber': instance.cardNumber,
      'cardHolder': instance.cardHolder,
      'expiryDate': instance.expiryDate,
      'cardBrand': instance.cardBrand,
      'isDefault': instance.isDefault,
    };

const _$PaymentTypeEnumMap = {
  PaymentType.card: 'card',
  PaymentType.cash: 'cash',
  PaymentType.transfer: 'transfer',
  PaymentType.other: 'other',
};
