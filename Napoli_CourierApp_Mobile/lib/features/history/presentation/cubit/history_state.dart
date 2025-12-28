import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/delivery_period.dart';

/// Estados del historial de entregas
sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Cargando historial
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Historial cargado exitosamente
class HistoryLoaded extends HistoryState {
  final List<Order> orders;
  final double totalEarnings;
  final int deliveryCount;
  final DeliveryPeriod period;

  const HistoryLoaded({
    required this.orders,
    required this.totalEarnings,
    required this.deliveryCount,
    required this.period,
  });

  double get averageEarnings =>
      deliveryCount > 0 ? totalEarnings / deliveryCount : 0;

  @override
  List<Object?> get props => [orders, totalEarnings, deliveryCount, period];
}

/// Error al cargar historial
class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
