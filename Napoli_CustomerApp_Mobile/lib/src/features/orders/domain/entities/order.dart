import 'package:equatable/equatable.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';
import 'package:napoli_app_v1/src/features/cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  delivering,
  completed,
  cancelled,
}

class Order extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final int total;
  final OrderStatus status;
  final DateTime date;
  final AddressModel address;
  final String paymentMethod;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.date,
    required this.address,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    total,
    status,
    date,
    address,
    paymentMethod,
  ];
}
