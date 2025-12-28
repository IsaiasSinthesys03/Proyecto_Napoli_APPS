import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/mock_dashboard_datasource.dart';

/// Implementación del repositorio del dashboard
class DashboardRepositoryImpl implements DashboardRepository {
  final MockDashboardDataSource dataSource;

  const DashboardRepositoryImpl(this.dataSource);

  @override
  Future<Either<String, bool>> toggleOnlineStatus({
    required String driverId,
    required bool isOnline,
  }) async {
    try {
      final result = await dataSource.setOnlineStatus(driverId, isOnline);
      return right(result);
    } catch (e) {
      return left('Error al cambiar estado: ${e.toString()}');
    }
  }

  @override
  Future<bool> getOnlineStatus(String driverId) async {
    return dataSource.getOnlineStatus(driverId);
  }
}
