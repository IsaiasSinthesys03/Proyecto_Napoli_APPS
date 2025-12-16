import 'package:napoli_app_v1/src/features/settings/domain/entities/order_history.dart';

/// Abstract interface for order history data access.
/// Implemented by SupabaseOrderHistoryRepository for database operations.
abstract class OrderHistoryRepository {
  /// Returns a list of all orders for the current user from Supabase.
  Future<List<OrderHistory>> getOrders(String customerId);

  /// Updates the rating for a specific order.
  Future<void> updateOrderRating(String orderId, int rating);
}
