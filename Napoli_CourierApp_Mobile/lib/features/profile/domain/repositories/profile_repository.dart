import 'package:fpdart/fpdart.dart';
import '../entities/driver_profile.dart';
import '../../../auth/domain/entities/driver.dart';

/// Repository para gestionar el perfil del conductor
abstract class ProfileRepository {
  /// Obtiene el perfil completo de un conductor
  Future<Either<String, DriverProfile>> getProfile(String driverId);

  /// Actualiza la información del conductor
  Future<Either<String, Driver>> updateDriver(Driver driver);

  /// Cambia la contraseña del conductor
  Future<Either<String, void>> changePassword(
    String driverId,
    String oldPassword,
    String newPassword,
  );

  /// Actualiza las configuraciones de la aplicación
  Future<Either<String, DriverProfile>> updateSettings(
    String driverId,
    Map<String, dynamic> settings,
  );
}
