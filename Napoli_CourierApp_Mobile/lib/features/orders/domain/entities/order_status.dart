/// Estados posibles de un pedido
enum OrderStatus {
  /// Pedido disponible para ser aceptado
  available,

  /// Pedido aceptado por el repartidor
  accepted,

  /// Pedido recogido del restaurante
  pickedUp,

  /// Repartidor en camino al cliente
  onTheWay,

  /// Pedido entregado
  delivered,

  /// Pedido cancelado
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.available:
        return 'Disponible';
      case OrderStatus.accepted:
        return 'Aceptado';
      case OrderStatus.pickedUp:
        return 'Recogido';
      case OrderStatus.onTheWay:
        return 'En Camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  /// Obtiene el botón de acción correspondiente al estado
  String get actionButtonLabel {
    switch (this) {
      case OrderStatus.available:
        return 'Aceptar Pedido';
      case OrderStatus.accepted:
        return 'Confirmar Recogida';
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        return 'Marcar Entregado';
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return '';
    }
  }
}
