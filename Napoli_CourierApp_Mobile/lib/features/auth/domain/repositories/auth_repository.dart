import 'package:fpdart/fpdart.dart';
import '../entities/driver.dart';

/// Repositorio abstracto de autenticación
/// Define el contrato que debe cumplir cualquier implementación
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña
  /// Retorna Either con error (Left) o Driver (Right)
  Future<Either<String, Driver>> login({
    required String email,
    required String password,
  });

  /// Registra un nuevo repartidor
  /// El repartidor se crea con status 'pending'
  Future<Either<String, Driver>> register({
    required String restaurantId,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? photoUrl,
  });

  /// Cierra la sesión actual
  Future<void> logout();

  /// Obtiene el repartidor actualmente autenticado
  Future<Driver?> getCurrentDriver();
}
