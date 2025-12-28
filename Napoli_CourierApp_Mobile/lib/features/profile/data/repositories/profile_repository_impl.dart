import 'package:fpdart/fpdart.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/domain/entities/driver.dart';
import '../datasources/profile_remote_datasource.dart';

/// Implementación del repositorio de perfil usando Supabase
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, DriverProfile>> getProfile(String driverId) async {
    try {
      final profile = await _dataSource.getProfile(driverId);
      return right(profile);
    } catch (e) {
      return left('Error al cargar el perfil: $e');
    }
  }

  @override
  Future<Either<String, Driver>> updateDriver(Driver driver) async {
    try {
      final updatedDriver = await _dataSource.updateDriver(driver);
      return right(updatedDriver);
    } catch (e) {
      return left('Error al actualizar el perfil: $e');
    }
  }

  @override
  Future<Either<String, void>> changePassword(
    String driverId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _dataSource.changePassword(driverId, oldPassword, newPassword);
      return right(null);
    } catch (e) {
      return left('Error al cambiar la contraseña: $e');
    }
  }

  @override
  Future<Either<String, DriverProfile>> updateSettings(
    String driverId,
    Map<String, dynamic> settings,
  ) async {
    try {
      final profile = await _dataSource.updateSettings(driverId, settings);
      return right(profile);
    } catch (e) {
      return left('Error al actualizar configuración: $e');
    }
  }
}
