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
    final client = SupabaseConfig.client;

    // Fetch customer details for snapshot
    final customerDataQuery = await client
        .from('customers')
        .select('name, email, phone')
        .eq('restaurant_id', _configService.restaurantId) // Security check
        .eq('id', customerId)
        .maybeSingle();

    // Default to empty strings if not found (should not happen if logged in)
    final customerSnapshot = {
      'name': customerDataQuery?['name'] ?? 'Guest',
      'email': customerDataQuery?['email'] ?? '',
      'phone': customerDataQuery?['phone'] ?? '',
    };

    // Construct address snapshot matching Admin Web expectation
    // Admin expects: { street, city, lat, lng }
    final addressSnapshot = {
      'street': order.address.address,
      'address_details': order.address.details, // Extra info
      'city': order.address.city,
      'state': '', // AddressModel doesn't have state yet
      'postal_code': '',
      'country': '',
      'lat': order.address.latitude ?? 0.0,
      'lng': order.address.longitude ?? 0.0,
      'label': order.address.label,
    };

    // Create the order record
    final orderData = await client
        .from('orders')
        .insert({
          'restaurant_id': _configService.restaurantId,
          'customer_id': customerId,
          'status': 'pending',
          'subtotal_cents': order.total,
          'delivery_fee_cents': 0,
          'discount_cents': 0,
          'total_cents': order.total,
          'payment_method': order.paymentMethod,
          'order_type': 'delivery',
          'address_snapshot': addressSnapshot,
          'customer_snapshot': customerSnapshot,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    // Create order items
    for (final item in order.itemsModel) {
      final addons = item.extras
          .map((e) => {'name': e.name, 'price_cents': e.price})
          .toList();

      await client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item.productId,
        'product_name': item.name,
        'quantity': item.quantity,
        'unit_price_cents': item.price,
        'subtotal_cents': item.price * item.quantity,
        'addons_snapshot': addons,
      });
    }

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
  }

  @override
  Future<List<OrderModel>> getOrders(String customerId) async {
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

    return (ordersData as List).map((data) {
      return _parseOrderFromData(data);
    }).toList();
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final client = SupabaseConfig.client;

    final orderData = await client
        .from('orders')
        .select('''
          *,
          order_items(*)
        ''')
        .eq('id', orderId)
        .maybeSingle();

    if (orderData == null) return null;
    return _parseOrderFromData(orderData);
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
