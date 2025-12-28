import 'package:fpdart/fpdart.dart' hide Order;
import '../../../orders/domain/entities/order.dart';
import '../entities/delivery_period.dart';

/// Repository para obtener el historial de entregas
abstract class HistoryRepository {
  /// Obtiene las entregas completadas para un conductor en un período específico
  Future<Either<String, List<Order>>> getCompletedOrders(
    String driverId,
    DeliveryPeriod period,
  );
}
