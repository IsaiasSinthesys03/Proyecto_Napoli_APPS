import 'package:equatable/equatable.dart';
import 'order_status.dart';
import 'order_item.dart';
import 'delivery_address.dart';

/// Entidad de pedido completa
class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final DeliveryAddress deliveryAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final double driverEarnings;
  final double distanceKm;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.driverEarnings,
    required this.distanceKm,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  /// Total de items en el pedido
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Copia el pedido con campos modificados
  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    DeliveryAddress? deliveryAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    double? driverEarnings,
    double? distanceKm,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      driverEarnings: driverEarnings ?? this.driverEarnings,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    customerName,
    customerPhone,
    deliveryAddress,
    items,
    subtotal,
    deliveryFee,
    total,
    driverEarnings,
    distanceKm,
    status,
    createdAt,
    acceptedAt,
    pickedUpAt,
    deliveredAt,
  ];
}
