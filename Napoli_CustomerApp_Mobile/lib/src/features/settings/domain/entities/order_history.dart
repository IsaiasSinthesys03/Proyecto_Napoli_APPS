import 'package:equatable/equatable.dart';

enum OrderHistoryStatus { delivered, inProgress, cancelled }

class OrderHistory extends Equatable {
  final String id;
  final DateTime date;
  final OrderHistoryStatus status;
  final List<OrderHistoryItem> items;
  final double total;
  final String paymentMethod;
  final String deliveryAddress;
  final String deliveryTime;
  final int? rating;
  final String? cancellationReason;

  const OrderHistory({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.deliveryTime,
    this.rating,
    this.cancellationReason,
  });

  // Clone with changes
  OrderHistory copyWith({
    String? id,
    DateTime? date,
    OrderHistoryStatus? status,
    List<OrderHistoryItem>? items,
    double? total,
    String? paymentMethod,
    String? deliveryAddress,
    String? deliveryTime,
    int? rating,
    String? cancellationReason,
  }) {
    return OrderHistory(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      rating: rating ?? this.rating,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    status,
    items,
    total,
    paymentMethod,
    deliveryAddress,
    deliveryTime,
    rating,
    cancellationReason,
  ];
}

class OrderHistoryItem extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  const OrderHistoryItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [productId, name, quantity, price];
}
