import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../orders/domain/entities/delivery_address.dart';
import '../../domain/entities/delivery_period.dart';

/// Fuente de datos mock para el historial de entregas
class MockHistoryDataSource {
  /// Obtiene pedidos completados según el período
  Future<List<Order>> getCompletedOrders(
    String driverId,
    DeliveryPeriod period,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final allOrders = _generateCompletedOrders(now);

    // Filtrar según el período
    return allOrders.where((order) {
      final orderDate = order.createdAt;
      switch (period) {
        case DeliveryPeriod.today:
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day;
        case DeliveryPeriod.week:
          final weekAgo = now.subtract(const Duration(days: 7));
          return orderDate.isAfter(weekAgo);
        case DeliveryPeriod.month:
          return orderDate.year == now.year && orderDate.month == now.month;
      }
    }).toList();
  }

  /// Genera 20 pedidos completados con fechas variadas
  List<Order> _generateCompletedOrders(DateTime now) {
    final orders = <Order>[];

    // 3 pedidos de hoy
    orders.addAll(_generateOrdersForDay(now, 3, startId: 2001));

    // 5 pedidos de hace 2-6 días (esta semana)
    for (int i = 2; i <= 6; i++) {
      final date = now.subtract(Duration(days: i));
      orders.add(_generateOrdersForDay(date, 1, startId: 2000 + i + 3).first);
    }

    // 12 pedidos del mes (hace 7-30 días)
    for (int i = 7; i <= 18; i++) {
      final date = now.subtract(Duration(days: i));
      orders.add(_generateOrdersForDay(date, 1, startId: 2000 + i + 8).first);
    }

    return orders..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Genera pedidos para un día específico
  List<Order> _generateOrdersForDay(
    DateTime date,
    int count, {
    required int startId,
  }) {
    final orders = <Order>[];

    for (int i = 0; i < count; i++) {
      final orderId = (startId + i).toString();
      final hour = 10 + (i * 2); // 10:00, 12:00, 14:00, etc.
      final orderTime = DateTime(date.year, date.month, date.day, hour, 30);

      orders.add(
        Order(
          id: orderId,
          orderNumber: '#${2000 + startId + i}',
          customerName: _getCustomerName(i),
          customerPhone: '+54 11 ${1000 + i}-${5000 + i}',
          status: OrderStatus.delivered,
          items: _getOrderItems(i),
          subtotal: 800 + (i * 100),
          deliveryFee: 150,
          total: 950 + (i * 100),
          driverEarnings: 50 + (i * 10),
          deliveryAddress: _getDeliveryAddress(i),
          createdAt: orderTime,
          acceptedAt: orderTime.add(const Duration(minutes: 2)),
          pickedUpAt: orderTime.add(const Duration(minutes: 15)),
          deliveredAt: orderTime.add(const Duration(minutes: 30)),
          distanceKm: 2.5 + (i * 0.5),
        ),
      );
    }

    return orders;
  }

  String _getCustomerName(int index) {
    final names = [
      'Juan Pérez',
      'María González',
      'Carlos Rodríguez',
      'Ana Martínez',
      'Luis Fernández',
      'Laura López',
      'Diego Sánchez',
      'Sofía Romero',
      'Pablo Torres',
      'Valentina Díaz',
    ];
    return names[index % names.length];
  }

  List<OrderItem> _getOrderItems(int index) {
    final items = [
      [OrderItem(name: 'Pizza Napolitana', quantity: 2, price: 400)],
      [
        OrderItem(name: 'Pizza Muzzarella', quantity: 1, price: 350),
        OrderItem(name: 'Empanadas x12', quantity: 1, price: 450),
      ],
      [
        OrderItem(name: 'Pizza Calabresa', quantity: 1, price: 420),
        OrderItem(name: 'Fainá', quantity: 1, price: 180),
        OrderItem(name: 'Coca Cola 1.5L', quantity: 1, price: 200),
      ],
    ];
    return items[index % items.length];
  }

  DeliveryAddress _getDeliveryAddress(int index) {
    final addresses = [
      DeliveryAddress(
        street: 'Av. Libertador 1234',
        details: 'Palermo',
        notes: 'Timbre 4B',
        latitude: -34.603722,
        longitude: -58.381592,
      ),
      DeliveryAddress(
        street: 'Av. Santa Fe 5678',
        details: 'Recoleta',
        notes: 'Portero eléctrico',
        latitude: -34.595722,
        longitude: -58.391592,
      ),
      DeliveryAddress(
        street: 'Av. Corrientes 9012',
        details: 'Almagro',
        latitude: -34.603000,
        longitude: -58.411000,
      ),
      DeliveryAddress(
        street: 'Av. Cabildo 3456',
        details: 'Belgrano',
        notes: 'Dejar con portero',
        latitude: -34.560000,
        longitude: -58.450000,
      ),
      DeliveryAddress(
        street: 'Av. Rivadavia 7890',
        details: 'Caballito',
        notes: 'Casa con rejas verdes',
        latitude: -34.620000,
        longitude: -58.440000,
      ),
    ];
    return addresses[index % addresses.length];
  }
}
