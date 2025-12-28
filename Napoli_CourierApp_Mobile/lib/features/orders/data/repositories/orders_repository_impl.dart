import 'package:fpdart/fpdart.dart' hide Order;
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

/// Implementación del repositorio de pedidos
class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource dataSource;
  final String restaurantId;

  const OrdersRepositoryImpl(this.dataSource, this.restaurantId);

  @override
  Future<Either<String, List<Order>>> getAvailableOrders() async {
    try {
      final orders = await dataSource.getAvailableOrders(restaurantId);
      return right(orders);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, List<Order>>> getActiveOrders(String driverId) async {
    try {
      final orders = await dataSource.getMyOrders(
        driverId,
        status: 'delivering',
      );
      return right(orders);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Order>> getOrderById(String orderId) async {
    try {
      final order = await dataSource.getOrderDetails(orderId);
      return right(order);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Order>> acceptOrder(
    String orderId,
    String driverId,
  ) async {
    try {
      final order = await dataSource.acceptOrder(orderId, driverId);
      return right(order);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Order>> confirmPickup(String orderId) async {
    return left('Use pickupOrder from datasource with driver ID');
  }

  @override
  Future<Either<String, Order>> markOnTheWay(String orderId) async {
    return left('Use pickupOrder from datasource with driver ID');
  }

  @override
  Future<Either<String, Order>> markDelivered(String orderId) async {
    return left('Use completeOrder from datasource with driver ID');
  }

  @override
  Future<Either<String, Order>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    // Status updates are handled by specific methods (acceptOrder, completeOrder)
    return left('Use specific methods (acceptOrder, markDelivered) instead');
  }

  /// Complete order (mark as delivered)
  Future<Either<String, Order>> completeOrder(
    String orderId,
    String driverId,
  ) async {
    try {
      final order = await dataSource.completeOrder(orderId, driverId);
      return right(order);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Get driver's order history
  Future<Either<String, List<Order>>> getOrderHistory(
    String driverId, {
    String? status,
  }) async {
    try {
      final orders = await dataSource.getMyOrders(driverId, status: status);
      return right(orders);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Pickup order (confirm pickup) - requires driver ID
  Future<Either<String, Order>> pickupOrder(
    String orderId,
    String driverId,
  ) async {
    try {
      final order = await dataSource.pickupOrder(orderId, driverId);
      return right(order);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
