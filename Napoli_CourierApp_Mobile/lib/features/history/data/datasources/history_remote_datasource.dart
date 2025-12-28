import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/delivery_address.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../domain/entities/delivery_period.dart';

/// Remote data source para historial de entregas
class HistoryRemoteDataSource {
  final SupabaseClient _client;

  HistoryRemoteDataSource(this._client);

  /// Obtiene pedidos completados del driver filtrados por período
  Future<List<Order>> getCompletedOrders(
    String driverId,
    DeliveryPeriod period,
  ) async {
    try {
      print('🔍 DEBUG - Getting completed orders for driver: $driverId');

      final result = await _client.rpc(
        'get_driver_orders',
        params: {'p_driver_id': driverId, 'p_status': 'delivered'},
      );

      print('✅ Got completed orders result');

      if (result == null) {
        return [];
      }

      final orders = (result as List)
          .map((json) => _orderFromJson(json as Map<String, dynamic>))
          .toList();

      print('📦 Parsed ${orders.length} completed orders');

      // Filtrar por período
      final filtered = _filterByPeriod(orders, period);
      print(
        '✅ Filtered to ${filtered.length} orders for period: ${period.name}',
      );

      return filtered;
    } catch (e) {
      print('❌ Error getting completed orders: $e');
      throw Exception('Error al obtener historial: $e');
    }
  }

  /// Filtra pedidos por período
  List<Order> _filterByPeriod(List<Order> orders, DeliveryPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case DeliveryPeriod.today:
        return orders.where((order) {
          if (order.deliveredAt == null) return false;
          final deliveredAt = order.deliveredAt!;
          return deliveredAt.year == now.year &&
              deliveredAt.month == now.month &&
              deliveredAt.day == now.day;
        }).toList();

      case DeliveryPeriod.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        return orders.where((order) {
          return order.deliveredAt != null &&
              order.deliveredAt!.isAfter(weekAgo);
        }).toList();

      case DeliveryPeriod.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        return orders.where((order) {
          return order.deliveredAt != null &&
              order.deliveredAt!.isAfter(monthAgo);
        }).toList();
    }
  }

  /// Helper: Parse JSON to Order entity
  Order _orderFromJson(Map<String, dynamic> json) {
    // Parse customer info
    final customerName = json['customer_name'] as String? ?? 'Cliente';
    final customerPhone = ''; // Hidden for privacy in history

    // Parse delivery address
    final deliveryAddress = DeliveryAddress(
      street: json['delivery_address'] as String? ?? '',
      latitude: 0.0, // Hidden for privacy
      longitude: 0.0, // Hidden for privacy
    );

    // Parse status
    final statusStr = json['status'] as String? ?? 'delivered';
    final status = _parseOrderStatus(statusStr);

    // Parse items
    final itemsJson = json['items'] as List? ?? [];
    final items = itemsJson.map((item) {
      return OrderItem(
        name: item['product_name'] as String? ?? '',
        quantity: item['quantity'] as int? ?? 1,
        price: (item['total_price_cents'] as int? ?? 0) / 100.0,
        notes: item['notes'] as String?,
      );
    }).toList();

    // Parse costs
    final subtotalCents = json['subtotal_cents'] as int? ?? 0;
    final deliveryFeeCents = json['delivery_fee_cents'] as int? ?? 0;
    final totalCents = json['total_cents'] as int? ?? 0;

    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      items: items,
      subtotal: subtotalCents / 100.0,
      deliveryFee: deliveryFeeCents / 100.0,
      total: totalCents / 100.0,
      driverEarnings: deliveryFeeCents / 100.0, // Driver earns the delivery fee
      distanceKm: 0.0,
      status: status,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: null, // Not needed for history
      pickedUpAt: null, // Not needed for history
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  /// Helper: Parse order status from string
  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
      case 'ready':
        return OrderStatus.available;
      case 'accepted':
        return OrderStatus.accepted;
      case 'delivering':
        return OrderStatus.pickedUp;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.delivered;
    }
  }
}
