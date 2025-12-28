import 'package:fpdart/fpdart.dart' hide Order;
import '../../../orders/domain/entities/order.dart';
import '../../domain/entities/delivery_period.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';

/// Implementación del repositorio de historial usando Supabase
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _dataSource;

  HistoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, List<Order>>> getCompletedOrders(
    String driverId,
    DeliveryPeriod period,
  ) async {
    try {
      final orders = await _dataSource.getCompletedOrders(driverId, period);
      return Right(orders);
    } catch (e) {
      return Left('Error al cargar el historial: ${e.toString()}');
    }
  }
}
