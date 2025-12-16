import 'package:fpdart/fpdart.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  /// Get orders from local cache
  Future<Either<Failure, List<Order>>> getOrders();

  /// Save order to local cache only
  Future<Either<Failure, void>> saveOrder(Order order);

  /// Create order in Supabase and save locally
  Future<Either<Failure, Order>> createOrder(Order order, String customerId);

  /// Get orders from Supabase for a customer
  Future<Either<Failure, List<Order>>> getOrdersFromServer(String customerId);

  /// Watch order status changes in real-time
  Stream<Order> watchOrderStatus(String orderId);
}
