import 'package:fpdart/fpdart.dart' hide Order;
import '../entities/order.dart';
import '../entities/order_status.dart';

/// Repositorio abstracto de pedidos
abstract class OrdersRepository {
  /// Obtiene todos los pedidos disponibles para el repartidor
  Future<Either<String, List<Order>>> getAvailableOrders();

  /// Obtiene los pedidos en curso del repartidor
  Future<Either<String, List<Order>>> getActiveOrders(String driverId);

  /// Obtiene un pedido por ID
  Future<Either<String, Order>> getOrderById(String orderId);

  /// Acepta un pedido
  Future<Either<String, Order>> acceptOrder(String orderId, String driverId);

  /// Confirma que el pedido fue recogido
  Future<Either<String, Order>> confirmPickup(String orderId);

  /// Marca el pedido como en camino
  Future<Either<String, Order>> markOnTheWay(String orderId);

  /// Marca el pedido como entregado
  Future<Either<String, Order>> markDelivered(String orderId);

  /// Actualiza el estado de un pedido
  Future<Either<String, Order>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  );

  /// Confirma recogida del pedido (con driver ID)
  Future<Either<String, Order>> pickupOrder(String orderId, String driverId);

  /// Completa el pedido (marca como entregado)
  Future<Either<String, Order>> completeOrder(String orderId, String driverId);
}
