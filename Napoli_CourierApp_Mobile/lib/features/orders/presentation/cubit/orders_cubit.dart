import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/entities/order_status.dart';
import 'orders_state.dart';

/// Cubit para gestionar pedidos
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRepository repository;

  OrdersCubit(this.repository) : super(const OrdersInitial()) {
    print('📦 OrdersCubit created');
  }

  /// Carga todos los pedidos (disponibles y activos)
  Future<void> loadOrders(String driverId) async {
    print('📦 OrdersCubit.loadOrders called for driver: $driverId');
    emit(const OrdersLoading());
    print('📦 OrdersCubit emitted OrdersLoading state');

    try {
      final availableResult = await repository.getAvailableOrders();
      print('📦 OrdersCubit got available orders result');

      final activeResult = await repository.getActiveOrders(driverId);
      print('📦 OrdersCubit got active orders result');

      availableResult.fold(
        (error) {
          print('❌ OrdersCubit error loading available orders: $error');
          emit(OrdersError(error));
        },
        (availableOrders) {
          print(
            '✅ OrdersCubit loaded ${availableOrders.length} available orders',
          );
          activeResult.fold(
            (error) {
              print('❌ OrdersCubit error loading active orders: $error');
              emit(OrdersError(error));
            },
            (activeOrders) {
              print(
                '✅ OrdersCubit loaded ${activeOrders.length} active orders',
              );
              emit(
                OrdersLoaded(
                  availableOrders: availableOrders,
                  activeOrders: activeOrders,
                ),
              );
              print('📦 OrdersCubit emitted OrdersLoaded state');
            },
          );
        },
      );
    } catch (e) {
      print('❌ OrdersCubit exception in loadOrders: $e');
      emit(OrdersError(e.toString()));
    }
  }

  /// Carga un pedido específico
  Future<void> loadOrderDetail(String orderId) async {
    emit(const OrdersLoading());

    final result = await repository.getOrderById(orderId);

    result.fold(
      (error) => emit(OrdersError(error)),
      (order) => emit(OrderDetailLoaded(order)),
    );
  }

  /// Acepta un pedido
  Future<void> acceptOrder(String orderId, String driverId) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(OrderUpdating(currentState.order));

    final result = await repository.acceptOrder(orderId, driverId);

    result.fold((error) {
      emit(OrdersError(error));
      emit(currentState); // Volver al estado anterior
    }, (updatedOrder) => emit(OrderDetailLoaded(updatedOrder)));
  }

  /// Confirma recogida del pedido
  Future<void> confirmPickup(String orderId, String driverId) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(OrderUpdating(currentState.order));

    final result = await repository.pickupOrder(orderId, driverId);

    result.fold((error) {
      emit(OrdersError(error));
      emit(currentState);
    }, (updatedOrder) => emit(OrderDetailLoaded(updatedOrder)));
  }

  /// Marca pedido en camino (same as confirmPickup in our flow)
  Future<void> markOnTheWay(String orderId, String driverId) async {
    await confirmPickup(orderId, driverId);
  }

  /// Marca pedido como entregado
  Future<void> markDelivered(String orderId, String driverId) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(OrderUpdating(currentState.order));

    final result = await repository.completeOrder(orderId, driverId);

    result.fold((error) {
      emit(OrdersError(error));
      emit(currentState);
    }, (updatedOrder) => emit(OrderDetailLoaded(updatedOrder)));
  }

  /// Método auxiliar para actualizar estado
  Future<void> _updateStatus(
    String orderId,
    Future<dynamic> updateFuture,
  ) async {
    final currentState = state;
    if (currentState is! OrderDetailLoaded) return;

    emit(OrderUpdating(currentState.order));

    final result = await updateFuture;

    result.fold((error) {
      emit(OrdersError(error));
      emit(currentState); // Volver al estado anterior
    }, (updatedOrder) => emit(OrderDetailLoaded(updatedOrder)));
  }
}
