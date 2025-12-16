import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

enum PaymentType { card, cash, transfer, other }

@JsonSerializable()
class PaymentMethodModel {
  final String id;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cardBrand;
  bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cardBrand,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);
}
