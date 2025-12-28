import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/driver_model.dart';

/// Implementación del repositorio de autenticación usando Supabase
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;
  final SharedPreferences prefs;

  // Keys para SharedPreferences
  static const String _keyDriverId = 'driver_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  const AuthRepositoryImpl({required this.dataSource, required this.prefs});

  @override
  Future<Either<String, Driver>> login({
    required String email,
    required String password,
  }) async {
    try {
      final driverModel = await dataSource.login(
        email: email,
        password: password,
      );

      // Convertir a entidad
      final driver = driverModel.toEntity();

      // Guardar sesión
      await prefs.setString(_keyDriverId, driver.id);
      await prefs.setBool(_keyIsLoggedIn, true);

      return Right(driverModel.toEntity());
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Driver>> register({
    required String restaurantId,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? photoUrl,
  }) async {
    try {
      final driverModel = await dataSource.register(
        restaurantId: restaurantId,
        name: name,
        email: email,
        password: password,
        phone: phone,
        vehicleType: vehicleType,
        licensePlate: licensePlate,
        photoUrl: photoUrl,
      );

      final driver = driverModel.toEntity();

      // NO guardamos sesión aquí porque el usuario está pending
      // Solo retornamos el driver para mostrar pantalla de espera

      return right(driver);
    } catch (e) {
      return left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
    await prefs.remove(_keyDriverId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  @override
  Future<Driver?> getCurrentDriver() async {
    try {
      final driverModel = await dataSource.getCurrentDriver();
      return driverModel?.toEntity();
    } catch (e) {
      return null;
    }
  }
}
