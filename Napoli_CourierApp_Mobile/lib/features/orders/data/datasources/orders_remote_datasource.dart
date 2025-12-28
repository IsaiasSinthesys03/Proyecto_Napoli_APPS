// lib/features/orders/data/datasources/orders_remote_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/entities/order_status.dart';

class OrdersRemoteDataSource {
  final SupabaseClient _client;

  OrdersRemoteDataSource(this._client);

  /// 1. Obtener pedidos disponibles (status: ready)
  Future<List<Order>> getAvailableOrders(String restaurantId) async {
    try {
      print(
        '🔍 DEBUG - Getting available orders for restaurant: $restaurantId',
      );

      final result = await _client.rpc(
        'get_available_orders',
        params: {'p_restaurant_id': restaurantId},
      );

      print('🔍 DEBUG - Available orders result: $result');

      if (result == null) {
        print('⚠️ No available orders');
        return [];
      }

      final List<dynamic> ordersJson = result as List<dynamic>;
      final orders = ordersJson.map((json) => _orderFromJson(json)).toList();

      print('✅ Found ${orders.length} available orders');
      return orders;
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      throw Exception('Error al obtener pedidos: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  /// 2. Aceptar pedido
  Future<Order> acceptOrder(String orderId, String driverId) async {
    try {
      print('🔍 DEBUG - Accepting order: $orderId by driver: $driverId');

      final result = await _client.rpc(
        'accept_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );

      print('✅ Order accepted successfully');
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('no disponible')) {
        throw Exception('Este pedido ya no está disponible');
      }
      throw Exception('Error al aceptar pedido: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al aceptar pedido: $e');
    }
  }

  /// 2.5 Confirmar recogida del pedido (pickup)
  Future<Order> pickupOrder(String orderId, String driverId) async {
    try {
      print('🔍 DEBUG - Picking up order: $orderId by driver: $driverId');

      final result = await _client.rpc(
        'pickup_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );

      print('✅ Order picked up successfully');
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('no válido')) {
        throw Exception('No puedes confirmar la recogida de este pedido');
      }
      throw Exception('Error al confirmar recogida: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al confirmar recogida: $e');
    }
  }

  /// 3. Completar pedido (marcar como entregado)
  Future<Order> completeOrder(String orderId, String driverId) async {
    try {
      print('🔍 DEBUG - Completing order: $orderId by driver: $driverId');

      final result = await _client.rpc(
        'complete_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );

      print('✅ Order completed successfully');
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('no válido')) {
        throw Exception('No tienes permiso para completar este pedido');
      }
      throw Exception('Error al completar pedido: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al completar pedido: $e');
    }
  }

  /// 4. Obtener detalles de pedido
  Future<Order> getOrderDetails(String orderId) async {
    try {
      print('🔍 DEBUG - Getting order details: $orderId');

      final result = await _client.rpc(
        'get_order_details',
        params: {'p_order_id': orderId},
      );

      print('✅ Order details retrieved');
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('no encontrado')) {
        throw Exception('Pedido no encontrado');
      }
      throw Exception('Error al obtener detalles: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al obtener detalles: $e');
    }
  }

  /// 5. Obtener mis pedidos (historial)
  Future<List<Order>> getMyOrders(String driverId, {String? status}) async {
    try {
      print('🔍 DEBUG - Getting orders for driver: $driverId, status: $status');

      final result = await _client.rpc(
        'get_driver_orders',
        params: {'p_driver_id': driverId, 'p_status': status},
      );

      print('🔍 DEBUG - Driver orders result: $result');

      if (result == null) {
        print('⚠️ No orders found');
        return [];
      }

      final List<dynamic> ordersJson = result as List<dynamic>;
      final orders = ordersJson.map((json) => _orderFromJson(json)).toList();

      print('✅ Found ${orders.length} orders');
      return orders;
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      throw Exception('Error al obtener historial: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al obtener historial: $e');
    }
  }

  /// Helper: Convertir JSON a Order entity
  Order _orderFromJson(Map<String, dynamic> json) {
    // Parse items if available
    List<OrderItem> items = [];
    if (json['items'] != null) {
      final itemsJson = json['items'] as List<dynamic>;
      items = itemsJson
          .map(
            (item) => OrderItem(
              name: item['product_name'] as String,
              quantity: item['quantity'] as int,
              price: (item['unit_price_cents'] as int) / 100.0,
              notes: item['notes'] as String?,
            ),
          )
          .toList();
    }

    // Parse delivery address
    final deliveryAddress = DeliveryAddress(
      street: json['delivery_address'] as String? ?? '',
      details: null,
      notes: json['delivery_instructions'] as String?,
      latitude: (json['delivery_latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['delivery_longitude'] as num?)?.toDouble() ?? 0.0,
    );

    // Parse status
    final statusStr = json['status'] as String;
    final status = _parseOrderStatus(statusStr);

    // Parse customer info
    final customerName =
        json['customer_name'] as String? ??
        (json['customer'] != null
            ? (json['customer'] as Map<String, dynamic>)['name'] as String?
            : null) ??
        'Cliente';

    final customerPhone =
        json['customer_phone'] as String? ??
        (json['customer'] != null
            ? (json['customer'] as Map<String, dynamic>)['phone'] as String?
            : null) ??
        '';

    return Order(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      items: items,
      subtotal: (json['subtotal_cents'] as int?) != null
          ? (json['subtotal_cents'] as int) / 100.0
          : 0.0,
      deliveryFee: (json['delivery_fee_cents'] as int?) != null
          ? (json['delivery_fee_cents'] as int) / 100.0
          : 0.0,
      total: (json['total_cents'] as int) / 100.0,
      driverEarnings: (json['earnings_cents'] as int?) != null
          ? (json['earnings_cents'] as int) / 100.0
          : (json['delivery_fee_cents'] as int?) != null
          ? (json['delivery_fee_cents'] as int) / 100.0
          : 0.0,
      distanceKm: 0.0, // Not provided by stored procedure
      status: status,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
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
        return OrderStatus.available;
    }
  }
}
