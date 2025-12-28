import 'package:fpdart/fpdart.dart';

/// Repositorio abstracto del dashboard
abstract class DashboardRepository {
  /// Cambia el estado online/offline del repartidor
  Future<Either<String, bool>> toggleOnlineStatus({
    required String driverId,
    required bool isOnline,
  });

  /// Obtiene el estado online actual del repartidor
  Future<bool> getOnlineStatus(String driverId);
}
