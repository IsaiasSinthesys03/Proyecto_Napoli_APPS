import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/delivery_period.dart';
import '../../domain/repositories/history_repository.dart';
import 'history_state.dart';

/// Cubit para manejar el historial de entregas
class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _repository;
  String? _currentDriverId;

  HistoryCubit(this._repository) : super(const HistoryInitial());

  /// Carga el historial para un conductor y período
  Future<void> loadHistory(String driverId, DeliveryPeriod period) async {
    _currentDriverId = driverId;
    emit(const HistoryLoading());

    final result = await _repository.getCompletedOrders(driverId, period);

    result.fold((error) => emit(HistoryError(error)), (orders) {
      final totalEarnings = orders.fold<double>(
        0,
        (sum, order) => sum + order.driverEarnings,
      );

      emit(
        HistoryLoaded(
          orders: orders,
          totalEarnings: totalEarnings,
          deliveryCount: orders.length,
          period: period,
        ),
      );
    });
  }

  /// Cambia el período de filtro
  Future<void> changePeriod(DeliveryPeriod period) async {
    if (_currentDriverId == null) return;
    await loadHistory(_currentDriverId!, period);
  }
}
