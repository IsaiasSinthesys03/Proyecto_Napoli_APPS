enum OrderStatus {
  pending,
  accepted,
  processing,
  ready,
  delivering,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.accepted:
        return 'Aceptada';
      case OrderStatus.processing:
        return 'En preparación';
      case OrderStatus.ready:
        return 'Lista para recoger';
      case OrderStatus.delivering:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregada';
      case OrderStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get actionButtonLabel {
    switch (this) {
      case OrderStatus.ready:
        return 'Aceptar Pedido';
      case OrderStatus.accepted:
        // Asumiendo que 'accepted' es cuando el repartidor ya aceptó pero no ha recogido
        return 'Recoger Pedido';
      case OrderStatus.delivering:
        return 'Marcar Entregado';
      default:
        return '';
    }
  }
}
