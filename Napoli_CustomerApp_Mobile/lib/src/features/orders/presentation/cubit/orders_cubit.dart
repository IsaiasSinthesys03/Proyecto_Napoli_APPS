import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/usecases/save_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'orders_state.dart';

@injectable
class OrdersCubit extends Cubit<OrdersState> {
  final SaveOrderUseCase _saveOrderUseCase;
  final GetOrdersUseCase _getOrdersUseCase;

  OrdersCubit(this._saveOrderUseCase, this._getOrdersUseCase)
    : super(const OrdersInitial());

  Future<void> loadOrders() async {
    emit(const OrdersLoading());

    final result = await _getOrdersUseCase(NoParams());

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Create order in Supabase and save locally
  Future<Order?> saveOrder(Order order, String customerId) async {
    emit(const OrderSaving());

    final result = await _saveOrderUseCase(
      SaveOrderParams(order: order, customerId: customerId),
    );

    return result.fold(
      (failure) {
        emit(OrdersError(failure.message));
        return null;
      },
      (createdOrder) {
        emit(const OrderSaved());
        return createdOrder;
      },
    );
  }
}
