import 'package:equatable/equatable.dart';
import '../../domain/entities/order.dart';

/// Estados del OrdersCubit
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Estado de carga
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Estado con lista de pedidos cargados
class OrdersLoaded extends OrdersState {
  final List<Order> availableOrders;
  final List<Order> activeOrders;

  const OrdersLoaded({
    required this.availableOrders,
    required this.activeOrders,
  });

  @override
  List<Object?> get props => [availableOrders, activeOrders];
}

/// Estado de un pedido individual cargado
class OrderDetailLoaded extends OrdersState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

/// Estado de actualización de pedido
class OrderUpdating extends OrdersState {
  final Order order;

  const OrderUpdating(this.order);

  @override
  List<Object?> get props => [order];
}

/// Estado de error
class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
