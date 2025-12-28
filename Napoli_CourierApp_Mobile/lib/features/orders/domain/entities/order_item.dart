import 'package:equatable/equatable.dart';

/// Item individual de un pedido
class OrderItem extends Equatable {
  final String name;
  final int quantity;
  final double price;
  final String? notes;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.notes,
  });

  @override
  List<Object?> get props => [name, quantity, price, notes];
}
