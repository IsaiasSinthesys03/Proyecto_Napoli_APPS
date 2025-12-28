import 'package:fpdart/fpdart.dart';
import '../repositories/dashboard_repository.dart';

/// Caso de uso para cambiar estado online/offline
class ToggleOnlineStatusUseCase {
  final DashboardRepository repository;

  const ToggleOnlineStatusUseCase(this.repository);

  Future<Either<String, bool>> call({
    required String driverId,
    required bool isOnline,
  }) async {
    return repository.toggleOnlineStatus(
      driverId: driverId,
      isOnline: isOnline,
    );
  }
}
