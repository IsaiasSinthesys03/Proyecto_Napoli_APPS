import 'package:injectable/injectable.dart' hide Order;
import 'package:napoli_app_v1/src/core/network/supabase_config.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/features/cart/data/models/cart_item_model.dart';
import 'package:napoli_app_v1/src/features/products/data/models/product_model.dart';
import 'package:napoli_app_v1/src/features/orders/data/models/order_model.dart';
import 'package:napoli_app_v1/src/features/orders/domain/entities/order.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/address_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order, String customerId);
  Future<List<OrderModel>> getOrders(String customerId);
  Future<OrderModel?> getOrderById(String orderId);
  Stream<Order> watchOrderStatus(String orderId);
}

@LazySingleton(as: OrderRemoteDataSource)
class SupabaseOrderDataSource implements OrderRemoteDataSource {
  final RestaurantConfigService _configService;

  SupabaseOrderDataSource(this._configService);

  @override
  Future<OrderModel> createOrder(OrderModel order, String customerId) async {
    print('🔍 DEBUG - Starting createOrder for customer: $customerId');

    final client = SupabaseConfig.client;

    try {
      // Prepare items for stored procedure
      final itemsJson = order.itemsModel.map((item) {
        print('🔍 DEBUG - Cart item: ${item.name}');
        print('📦 DATA - Product ID: ${item.productId}');
        print('📦 DATA - Product ID type: ${item.productId.runtimeType}');

        return {
          'product_id': item.productId,
          'product_name': item.name,
          'quantity': item.quantity,
          'unit_price_cents': item.price,
          'total_price_cents': item.price * item.quantity,
          'notes': item.specialInstructions ?? '',
        };
      }).toList();

      print('📦 DATA - Items JSON: $itemsJson');

      // Prepare address snapshot
      final addressSnapshot = {
        'street': order.address.address,
        'address_details': order.address.details,
        'city': order.address.city,
        'state': '',
        'postal_code': '',
        'country': '',
        'lat': order.address.latitude ?? 0.0,
        'lng': order.address.longitude ?? 0.0,
        'label': order.address.label,
      };

      print('🔍 DEBUG - Calling create_customer_order stored procedure');
      print('📦 DATA - Items count: ${itemsJson.length}');
      print('📦 DATA - Total: ${order.total}');

      final response = await client.rpc(
        'create_customer_order',
        params: {
          'p_customer_id': customerId,
          'p_restaurant_id': _configService.restaurantId,
          'p_items': itemsJson,
          'p_address_snapshot': addressSnapshot,
          'p_payment_method': order.paymentMethod,
          'p_subtotal_cents': order.total,
          'p_total_cents': order.total,
          'p_delivery_fee_cents': 0,
          'p_discount_cents': 0,
          'p_customer_notes': order.customerNotes,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('❌ ERROR - Stored procedure returned null');
        throw Exception('Error al crear orden');
      }

      final orderData = response as Map<String, dynamic>;
      final orderId = orderData['id'] as String;

      print('✅ SUCCESS - Order created with ID: $orderId');

      return OrderModel(
        id: orderId,
        userId: customerId,
        itemsModel: order.itemsModel,
        total: order.total,
        status: OrderStatus.pending,
        date: DateTime.now(),
        address: order.address,
        paymentMethod: order.paymentMethod,
      );
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in createOrder: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrders(String customerId) async {
    print('🔍 DEBUG - Starting getOrders for customer: $customerId');

    final client = SupabaseConfig.client;

    try {
      print('🔍 DEBUG - Calling get_customer_orders stored procedure');
      print('📦 DATA - restaurant_id: ${_configService.restaurantId}');

      final response = await client.rpc(
        'get_customer_orders',
        params: {
          'p_customer_id': customerId,
          'p_restaurant_id': _configService.restaurantId,
        },
      );

      print('✅ SUCCESS - Stored procedure response received');
      print('📦 DATA - Response type: ${response.runtimeType}');

      if (response == null) {
        print('📦 DATA - No orders found, returning empty list');
        return [];
      }

      final ordersData = response as List;
      print('📦 DATA - Parsing ${ordersData.length} orders');

      final orders = ordersData
          .map((data) => _parseOrderFromData(data as Map<String, dynamic>))
          .toList();

      print('✅ SUCCESS - Orders parsed successfully');
      return orders;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getOrders: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    print('🔍 DEBUG - Starting getOrderById for order: $orderId');

    final client = SupabaseConfig.client;
    final currentUser = client.auth.currentUser;

    if (currentUser == null) {
      print('❌ ERROR - No authenticated user');
      return null;
    }

    try {
      // Get customer_id from current user
      final customerData = await client
          .from('customers')
          .select('id')
          .eq('email', currentUser.email!)
          .eq('restaurant_id', _configService.restaurantId)
          .maybeSingle();

      if (customerData == null) {
        print('❌ ERROR - Customer not found');
        return null;
      }

      final customerId = customerData['id'] as String;

      print('🔍 DEBUG - Calling get_order_details stored procedure');

      final response = await client.rpc(
        'get_order_details',
        params: {'p_order_id': orderId, 'p_customer_id': customerId},
      );

      print('✅ SUCCESS - Stored procedure response received');

      if (response == null) {
        print('📦 DATA - Order not found');
        return null;
      }

      final orderData = response as Map<String, dynamic>;
      print('📦 DATA - Parsing order details');

      final order = _parseOrderFromData(orderData);

      print('✅ SUCCESS - Order details parsed successfully');
      return order;
    } catch (e, stackTrace) {
      print('❌ ERROR - Exception in getOrderById: $e');
      print('❌ ERROR - Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Stream<Order> watchOrderStatus(String orderId) {
    final client = SupabaseConfig.client;

    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Order not found');
          }
          return _parseOrderFromData(data.first);
        });
  }

  OrderModel _parseOrderFromData(Map<String, dynamic> data) {
    final orderItems = (data['order_items'] as List? ?? []);

    final itemsModel = orderItems.map<CartItemModel>((itemData) {
      final addons = (itemData['addons_snapshot'] as List? ?? []);
      final extrasModel = addons.map<ProductExtraModel>((addon) {
        return ProductExtraModel(
          id: '', // snapshot might not have original ID
          name: addon['name'] as String? ?? '',
          price: addon['price_cents'] as int? ?? 0,
        );
      }).toList();

      return CartItemModel(
        id: itemData['product_id'] as String? ?? '',
        name: itemData['product_name'] as String? ?? '',
        image: '',
        price: itemData['unit_price_cents'] as int? ?? 0,
        quantity: itemData['quantity'] as int? ?? 1,
        selectedExtrasModel: extrasModel,
      );
    }).toList();

    return OrderModel(
      id: data['id'] as String,
      userId: data['customer_id'] as String? ?? '',
      itemsModel: itemsModel,
      total: data['total_cents'] as int? ?? 0,
      status: _parseStatus(data['status'] as String?),
      date: DateTime.parse(data['created_at'] as String),
      address: _parseAddress(data['address_snapshot']),
      paymentMethod: data['payment_method'] as String? ?? 'cash',
      customerNotes: data['customer_notes'] as String?,
    );
  }

  OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.preparing;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  AddressModel _parseAddress(dynamic addressSnapshot) {
    if (addressSnapshot == null) {
      return AddressModel(
        id: '',
        label: '',
        address: '',
        city: '',
        details: '',
        isDefault: false,
      );
    }

    if (addressSnapshot is Map<String, dynamic>) {
      return AddressModel(
        id: addressSnapshot['id'] as String? ?? '',
        label: addressSnapshot['label'] as String? ?? 'Delivery Address',
        // Handle field name variations (Admin uses 'street', App uses 'address', DB uses 'street_address')
        address:
            addressSnapshot['street'] as String? ??
            addressSnapshot['address'] as String? ??
            addressSnapshot['street_address'] as String? ??
            '',
        city: addressSnapshot['city'] as String? ?? '',
        details:
            addressSnapshot['address_details'] as String? ??
            addressSnapshot['details'] as String? ??
            '',
        isDefault: false,
        latitude: (addressSnapshot['lat'] ?? addressSnapshot['latitude'])
            ?.toDouble(),
        longitude: (addressSnapshot['lng'] ?? addressSnapshot['longitude'])
            ?.toDouble(),
      );
    }
    return AddressModel(
      id: '',
      label: '',
      address: addressSnapshot.toString(),
      city: '',
      details: '',
      isDefault: false,
    );
  }
}
