// lib/features/orders/data/datasources/orders_remote_datasource.dart

import 'package:flutter/foundation.dart';
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
      // Consulta directa a la tabla orders
      // Usamos select('*') para evitar problemas con relaciones complejas
      final result = await _client
          .from('orders')
          .select('*, customers:customer_id(id, name, phone)')
          .eq('restaurant_id', restaurantId)
          .filter('driver_id', 'is', null)
          .filter('status', 'in', ['ready', 'processing'])
          .order('created_at', ascending: false);

      if (result.isNotEmpty) {
        final List<dynamic> ordersJson = result;
        return ordersJson.map((json) => _orderFromJson(json)).toList();
      }

      return [];
    } catch (e) {
      // En caso de error, retornamos lista vacía para no romper la UI
      return [];
    }
  }

  /// 1.5 Obtener pedidos activos (accepted, delivering, picked_up)
  Future<List<Order>> getActiveOrders(String driverId) async {
    try {
      debugPrint(
        '🔍 getActiveOrders: Attempting to fetch active orders for driver: $driverId',
      );

      List<dynamic> ordersJson = [];

      // 1. Intenta query directa primero
      try {
        debugPrint('🔍 getActiveOrders: Trying direct query...');
        final response = await _client
            .from('orders')
            .select(
              '*, customers:customer_id(*)',
            ) // Traer TODO del cliente para evitar errores de nombres de columna
            .eq('driver_id', driverId)
            .filter('status', 'in', ['accepted', 'delivering']);

        debugPrint('✅ Direct query returned ${response.length} orders');
        if (response.isNotEmpty) {
          ordersJson = response;
        }
      } catch (e) {
        debugPrint(
          '⚠️ Direct query failed for driver $driverId: $e. Trying RPC fallback...',
        );
      }

      // 2. RPC Fallback si la query directa no devolvió resultados
      if (ordersJson.isEmpty) {
        try {
          debugPrint(
            '🔍 getActiveOrders: Trying RPC get_driver_orders with status filter...',
          );
          final result = await _client.rpc(
            'get_driver_orders',
            params: {'p_driver_id': driverId, 'p_status': 'accepted'},
          );
          if (result != null && (result as List).isNotEmpty) {
            ordersJson = result;
            debugPrint('✅ RPC (accepted) returned ${ordersJson.length} orders');
          }
        } catch (e) {
          debugPrint('⚠️ RPC fallback failed for driver $driverId: $e');
        }

        // Si aún no hay resultados, intenta sin filtro de estado
        if (ordersJson.isEmpty) {
          try {
            debugPrint(
              '🔍 getActiveOrders: Trying RPC get_driver_orders without status filter...',
            );
            final result = await _client.rpc(
              'get_driver_orders',
              params: {'p_driver_id': driverId, 'p_status': null},
            );
            if (result != null && (result as List).isNotEmpty) {
              ordersJson = result;
              debugPrint(
                '✅ RPC (no filter) returned ${ordersJson.length} orders, filtering locally...',
              );
              // Filtrar localmente por status
              ordersJson = ordersJson.where((order) {
                final status = order['status'] ?? '';
                return ['accepted', 'delivering', 'picked_up'].contains(status);
              }).toList();
              debugPrint(
                '✅ After local filter: ${ordersJson.length} active orders',
              );
            }
          } catch (e) {
            debugPrint('❌ RPC fallback (no filter) also failed: $e');
          }
        }
      }

      if (ordersJson.isNotEmpty) {
        final List<Order> orders = [];
        for (final item in ordersJson) {
          // Creamos una copia mutable del JSON para poder inyectar datos si es necesario
          final Map<String, dynamic> json = Map<String, dynamic>.from(
            item as Map,
          );

          try {
            // 1. Si falta customer_id (común en RPC), buscarlo en la tabla orders
            if (json['customer_id'] == null && json['id'] != null) {
              try {
                final orderSimple = await _client
                    .from('orders')
                    .select('customer_id')
                    .eq('id', json['id'])
                    .maybeSingle();
                if (orderSimple != null) {
                  json['customer_id'] = orderSimple['customer_id'];
                }
              } catch (_) {}
            }

            // 2. Si tenemos customer_id pero no datos de cliente, buscarlos en tabla customers
            if ((json['customers'] == null && json['customer'] == null) &&
                json['customer_id'] != null) {
              try {
                final customerData = await _client
                    .from('customers')
                    .select() // Trae todos los atributos, incluyendo 'phone'
                    .eq('id', json['customer_id'])
                    .maybeSingle();

                if (customerData != null) {
                  json['customers'] = customerData; // Inyectamos los datos
                  debugPrint(
                    '✅ Datos de cliente recuperados manualmente: ${customerData['phone']}',
                  );
                }
              } catch (_) {}
            }

            var order = _orderFromJson(json);

            // FIX: Si el teléfono sigue vacío (falló query directa y RPC de lista es incompleto),
            // intentamos obtener el detalle completo usando el RPC 'get_order_details'.
            if (order.customerPhone.isEmpty) {
              try {
                debugPrint(
                  '🔍 Phone empty for order ${order.id}. Fetching full details via RPC...',
                );
                final fullOrder = await getOrderDetails(order.id);
                if (fullOrder.customerPhone.isNotEmpty) {
                  order = fullOrder;
                  debugPrint(
                    '✅ Phone recovered via getOrderDetails: ${order.customerPhone}',
                  );
                }
              } catch (e) {
                debugPrint('⚠️ Failed to recover details for ${order.id}: $e');
              }
            }

            orders.add(order);
            debugPrint(
              '✅ Parsed order ${order.id} with status ${order.status}, customerPhone="${order.customerPhone}"',
            );
          } catch (e) {
            debugPrint('❌ Failed to parse order: $json. Error: $e');
          }
        }
        debugPrint(
          '📦 getActiveOrders returning ${orders.length} orders for driver $driverId',
        );
        return orders;
      }

      debugPrint(
        '⚠️ getActiveOrders: No active orders found for driver $driverId',
      );
      return [];
    } catch (e) {
      debugPrint('❌ getActiveOrders critical error for driver $driverId: $e');
      if (e.toString().contains('invalid input syntax for type uuid')) {
        debugPrint('⚠️ Driver ID "$driverId" is not a valid UUID');
      }
      return [];
    }
  }

  /// 2. Aceptar pedido
  Future<Order> acceptOrder(String orderId, String driverId) async {
    try {
      final result = await _client.rpc(
        'accept_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('invalid input syntax for type uuid')) {
        throw Exception(
          'Error de datos: El ID del conductor ("$driverId") no es un UUID válido.',
        );
      }
      if (e.message.contains('no disponible')) {
        throw Exception('Este pedido ya no está disponible');
      }
      throw Exception('Error al aceptar pedido: ${e.message}');
    } catch (e) {
      throw Exception('Error al aceptar pedido: $e');
    }
  }

  /// 2.5 Confirmar recogida del pedido (pickup)
  Future<Order> pickupOrder(String orderId, String driverId) async {
    try {
      final result = await _client.rpc(
        'pickup_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('invalid input syntax for type uuid')) {
        throw Exception(
          'Error de datos: El ID del conductor ("$driverId") no es un UUID válido.',
        );
      }
      if (e.message.contains('no válido')) {
        throw Exception('No puedes confirmar la recogida de este pedido');
      }
      throw Exception('Error al confirmar recogida: ${e.message}');
    } catch (e) {
      throw Exception('Error al confirmar recogida: $e');
    }
  }

  /// 3. Completar pedido (marcar como entregado)
  Future<Order> completeOrder(String orderId, String driverId) async {
    try {
      final result = await _client.rpc(
        'complete_order',
        params: {'p_order_id': orderId, 'p_driver_id': driverId},
      );
      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('invalid input syntax for type uuid')) {
        throw Exception(
          'Error de datos: El ID del conductor ("$driverId") no es un UUID válido.',
        );
      }
      if (e.message.contains('no válido')) {
        throw Exception('No tienes permiso para completar este pedido');
      }
      throw Exception('Error al completar pedido: ${e.message}');
    } catch (e) {
      throw Exception('Error al completar pedido: $e');
    }
  }

  /// 4. Obtener detalles de pedido
  Future<Order> getOrderDetails(String orderId) async {
    try {
      // Intentar obtener los detalles completos con relación a customers
      final result = await _client.rpc(
        'get_order_details',
        params: {'p_order_id': orderId},
      );

      debugPrint('✅ getOrderDetails RPC response: ${result.toString()}');

      return _orderFromJson(result as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('no encontrado')) {
        throw Exception('Pedido no encontrado');
      }
      throw Exception('Error al obtener detalles: ${e.message}');
    } catch (e) {
      print('❌ getOrderDetails error: $e');
      throw Exception('Error al obtener detalles: $e');
    }
  }

  /// 5. Obtener mis pedidos (historial)
  Future<List<Order>> getMyOrders(String driverId, {String? status}) async {
    try {
      List<dynamic> ordersJson = [];

      // 1. Direct Query
      try {
        var query = _client
            .from('orders')
            .select('*')
            .eq('driver_id', driverId);
        if (status != null) {
          query = query.eq('status', status);
        }
        final result = await query.order('created_at', ascending: false);
        if (result.isNotEmpty) ordersJson = result;
      } catch (e) {
        print('⚠️ History direct query failed: $e');
      }

      // 2. RPC Fallback
      if (ordersJson.isEmpty) {
        final result = await _client.rpc(
          'get_driver_orders',
          params: {'p_driver_id': driverId, 'p_status': status},
        );
        if (result != null) ordersJson = result as List<dynamic>;
      }

      if (ordersJson.isNotEmpty) {
        return ordersJson.map((json) => _orderFromJson(json)).toList();
      }

      return [];
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      if (e.message.contains('invalid input syntax for type uuid')) {
        throw Exception(
          'Error de datos: El ID del conductor ("$driverId") no es un UUID válido.',
        );
      }
      throw Exception('Error al obtener historial: ${e.message}');
    } catch (e) {
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
              // Manejo robusto del nombre del producto (RPC vs Direct Query)
              name: item['product_name'] != null
                  ? item['product_name'] as String
                  : (item['products'] != null &&
                        item['products']['name'] != null)
                  ? item['products']['name'] as String
                  : 'Producto',
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
    final statusStr = json['status'] as String? ?? 'pending';
    final status = _parseOrderStatus(statusStr);

    // Parse customer info
    String customerName = 'Cliente';
    if (json['customer_name'] != null) {
      customerName = json['customer_name'] as String;
    } else if (json['customer'] != null && json['customer'] is Map) {
      customerName = (json['customer'] as Map)['name'] as String? ?? 'Cliente';
    } else if (json['customers'] != null) {
      // Manejar respuesta de direct query con alias customers
      dynamic customerData = json['customers'];
      if (customerData is List && customerData.isNotEmpty) {
        customerData = customerData.first;
      }
      if (customerData is Map) {
        customerName = customerData['name'] as String? ?? 'Cliente';
      }
    }

    // Obtener el teléfono del cliente de varias fuentes posibles
    String customerPhone = '';

    // 1. Intentar obtener de 'customer_phone' (campo directo en orders)
    if (json['customer_phone'] != null) {
      final val = json['customer_phone'].toString();
      if (val.isNotEmpty && val != 'null') {
        customerPhone = val;
      }
    }

    // 2. Si está vacío, intentar del objeto 'customer' (RPC response)
    if (customerPhone.isEmpty &&
        json['customer'] != null &&
        json['customer'] is Map) {
      final customer = json['customer'] as Map;
      if (customer['phone'] != null) {
        customerPhone = customer['phone'].toString();
      }
    }

    // 3. Si sigue vacío, intentar de la relación 'customers' (Direct Query response)
    if (customerPhone.isEmpty && json['customers'] != null) {
      dynamic customerData = json['customers'];
      if (customerData is List && customerData.isNotEmpty) {
        customerData = customerData.first;
      }
      if (customerData is Map) {
        // Intentar varios nombres comunes para la columna de teléfono
        customerPhone =
            customerData['phone']?.toString() ??
            customerData['phone_number']?.toString() ??
            customerData['mobile']?.toString() ??
            '';
      }
    }

    // 4. Si sigue vacío, intentar de 'customer_snapshot' (si existe en el JSON, ej: Direct Query)
    if (customerPhone.isEmpty && json['customer_snapshot'] != null) {
      final snapshot = json['customer_snapshot'];
      if (snapshot is Map && snapshot['phone'] != null) {
        customerPhone = snapshot['phone'].toString();
      }
    }

    if (customerPhone.isEmpty) {
      debugPrint(
        '⚠️ _orderFromJson: Phone is EMPTY after checking all sources.',
      );
      // Imprimir el JSON completo para depurar si sigue fallando
      debugPrint('📋 JSON Dump: $json');
    }

    return Order(
      id: json['id'].toString(), // Asegurar String
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
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.tryParse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'] as String)
          : null,
    );
  }

  /// Helper: Parse order status from string
  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'processing':
      case 'ready':
        return OrderStatus.ready;
      case 'accepted':
        return OrderStatus.accepted;
      case 'delivering':
      case 'picked_up':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.ready;
    }
  }
}
