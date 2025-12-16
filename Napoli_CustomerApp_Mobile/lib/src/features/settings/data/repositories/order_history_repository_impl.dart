import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/order_history.dart';
import 'package:napoli_app_v1/src/features/settings/domain/repositories/order_history_repository.dart';

/// Supabase implementation of OrderHistoryRepository
@LazySingleton(as: OrderHistoryRepository)
class SupabaseOrderHistoryRepository implements OrderHistoryRepository {
  final RestaurantConfigService _configService;

  SupabaseOrderHistoryRepository(this._configService);

  @override
  Future<List<OrderHistory>> getOrders(String customerId) async {
    final client = SupabaseConfig.client;

    final ordersData = await client
        .from('orders')
        .select('''
          *,
          order_items(*)
        ''')
        .eq('restaurant_id', _configService.restaurantId)
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (ordersData as List).map((order) {
      final items =
          (order['order_items'] as List?)?.map((item) {
            return OrderHistoryItem(
              productId: item['product_id'] as String? ?? '',
              name: item['product_name'] as String? ?? '',
              quantity: item['quantity'] as int? ?? 1,
              price: ((item['unit_price_cents'] as int? ?? 0) / 100),
            );
          }).toList() ??
          [];

      return OrderHistory(
        id: order['order_number'] as String? ?? order['id'] as String,
        date: DateTime.parse(order['created_at'] as String),
        status: _parseStatus(order['status'] as String?),
        items: items,
        total: (order['total_cents'] as int? ?? 0) / 100,
        paymentMethod: order['payment_method'] as String? ?? 'Unknown',
        deliveryAddress: _parseAddress(order['address_snapshot']),
        deliveryTime: _estimateDeliveryTime(order),
        rating: order['customer_rating'] as int?,
      );
    }).toList();
  }

  OrderHistoryStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
      case 'accepted':
      case 'processing':
      case 'ready':
      case 'delivering':
        return OrderHistoryStatus.inProgress;
      case 'delivered':
        return OrderHistoryStatus.delivered;
      case 'cancelled':
        return OrderHistoryStatus.cancelled;
      default:
        return OrderHistoryStatus.inProgress;
    }
  }

  String _parseAddress(dynamic addressSnapshot) {
    if (addressSnapshot == null) return '';
    if (addressSnapshot is Map) {
      return '${addressSnapshot['street'] ?? ''}, ${addressSnapshot['city'] ?? ''}';
    }
    return addressSnapshot.toString();
  }

  String _estimateDeliveryTime(Map<String, dynamic> order) {
    final prepMinutes = order['estimated_prep_minutes'] as int? ?? 20;
    final deliveryMinutes = order['estimated_delivery_minutes'] as int? ?? 30;
    return '$prepMinutes-${prepMinutes + deliveryMinutes} min';
  }

  @override
  Future<void> updateOrderRating(String orderId, int rating) async {
    final client = SupabaseConfig.client;

    // orderId might be order_number or actual id
    await client
        .from('orders')
        .update({'customer_rating': rating})
        .eq('order_number', orderId);
  }
}
