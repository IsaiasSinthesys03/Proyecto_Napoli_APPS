import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/delivery_address.dart';
import '../../domain/entities/order_status.dart';

/// DataSource mock con 3 pedidos de prueba
class MockOrdersDataSource {
  static final List<Order> _mockOrders = [
    // Pedido 1: Disponible
    Order(
      id: '1',
      orderNumber: '#1001',
      customerName: 'Juan Pérez',
      customerPhone: '+5491123456789',
      deliveryAddress: const DeliveryAddress(
        street: 'Av. Libertador 1234',
        details: 'Piso 4, Depto B',
        notes: 'Tocar timbre 2 veces',
        latitude: -34.603722,
        longitude: -58.381592,
      ),
      items: const [
        OrderItem(
          name: 'Pizza Napoli Grande',
          quantity: 1,
          price: 850.0,
          notes: 'Sin cebolla',
        ),
        OrderItem(name: 'Coca-Cola 500ml', quantity: 2, price: 150.0),
      ],
      subtotal: 1150.0,
      deliveryFee: 200.0,
      total: 1350.0,
      driverEarnings: 150.0,
      distanceKm: 1.2,
      status: OrderStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),

    // Pedido 2: Disponible
    Order(
      id: '2',
      orderNumber: '#1002',
      customerName: 'María González',
      customerPhone: '+5491198765432',
      deliveryAddress: const DeliveryAddress(
        street: 'Av. Cabildo 2567',
        details: 'Casa con portón verde',
        notes: null,
        latitude: -34.560833,
        longitude: -58.456389,
      ),
      items: const [
        OrderItem(name: 'Pizza Muzzarella Mediana', quantity: 2, price: 700.0),
        OrderItem(name: 'Fainá', quantity: 1, price: 250.0),
        OrderItem(name: 'Cerveza Quilmes 1L', quantity: 1, price: 300.0),
      ],
      subtotal: 1950.0,
      deliveryFee: 250.0,
      total: 2200.0,
      driverEarnings: 180.0,
      distanceKm: 2.5,
      status: OrderStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),

    // Pedido 3: Disponible
    Order(
      id: '3',
      orderNumber: '#1003',
      customerName: 'Carlos Rodríguez',
      customerPhone: '+5491187654321',
      deliveryAddress: const DeliveryAddress(
        street: 'Av. Santa Fe 3890',
        details: 'Edificio Torre Norte, Piso 12',
        notes: 'Dejar en recepción si no atiende',
        latitude: -34.588056,
        longitude: -58.402222,
      ),
      items: const [
        OrderItem(name: 'Pizza Especial Grande', quantity: 1, price: 950.0),
        OrderItem(name: 'Empanadas de Carne x6', quantity: 1, price: 600.0),
      ],
      subtotal: 1550.0,
      deliveryFee: 220.0,
      total: 1770.0,
      driverEarnings: 160.0,
      distanceKm: 1.8,
      status: OrderStatus.available,
      createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  /// Obtiene todos los pedidos disponibles
  Future<List<Order>> getAvailableOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockOrders.where((o) => o.status == OrderStatus.available).toList();
  }

  /// Obtiene pedidos activos de un driver
  Future<List<Order>> getActiveOrders(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockOrders
        .where(
          (o) =>
              o.status != OrderStatus.available &&
              o.status != OrderStatus.delivered &&
              o.status != OrderStatus.cancelled,
        )
        .toList();
  }

  /// Obtiene un pedido por ID
  Future<Order?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza un pedido
  Future<Order> updateOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockOrders.indexWhere((o) => o.id == order.id);
    if (index == -1) {
      throw Exception('Pedido no encontrado');
    }

    _mockOrders[index] = order;
    return order;
  }

  /// Actualiza el estado de un pedido
  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Pedido no encontrado');
    }

    final now = DateTime.now();
    Order updatedOrder = _mockOrders[index].copyWith(status: newStatus);

    // Actualizar timestamps según el estado
    switch (newStatus) {
      case OrderStatus.accepted:
        updatedOrder = updatedOrder.copyWith(acceptedAt: now);
        break;
      case OrderStatus.pickedUp:
        updatedOrder = updatedOrder.copyWith(pickedUpAt: now);
        break;
      case OrderStatus.delivered:
        updatedOrder = updatedOrder.copyWith(deliveredAt: now);
        break;
      default:
        break;
    }

    _mockOrders[index] = updatedOrder;
    return updatedOrder;
  }
}
