// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  itemsModel: (json['items'] as List<dynamic>)
      .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  date: DateTime.parse(json['date'] as String),
  address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
  paymentMethod: json['paymentMethod'] as String,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'total': instance.total,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'date': instance.date.toIso8601String(),
      'address': instance.address.toJson(),
      'paymentMethod': instance.paymentMethod,
      'items': instance.itemsModel.map((e) => e.toJson()).toList(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.delivering: 'delivering',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};
