import 'package:json_annotation/json_annotation.dart';
import 'package:napoli_app_v1/src/features/orders/domain/entities/order.dart';
import 'package:napoli_app_v1/src/features/cart/data/models/cart_item_model.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderModel extends Order {
  @JsonKey(name: 'items')
  final List<CartItemModel> itemsModel;

  const OrderModel({
    required super.id,
    required super.userId,
    required this.itemsModel,
    required super.total,
    required super.status,
    required super.date,
    required super.address,
    required super.paymentMethod,
    super.customerNotes,
  }) : super(items: itemsModel);

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      itemsModel: order.items.map((e) => CartItemModel.fromEntity(e)).toList(),
      total: order.total,
      status: order.status,
      date: order.date,
      address: order.address,
      paymentMethod: order.paymentMethod,
      customerNotes: order.customerNotes,
    );
  }
}
