import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/domain/entities/driver.dart';
import '../../../auth/domain/entities/vehicle_type.dart';
import '../../../auth/domain/entities/driver_status.dart';
import '../../domain/entities/driver_profile.dart';

/// Fuente de datos mock para el perfil del conductor
class MockProfileDataSource {
  final SharedPreferences _prefs;

  MockProfileDataSource(this._prefs);

  /// Obtiene el perfil del conductor
  Future<DriverProfile> getProfile(String driverId) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Obtener configuraciones guardadas
    final notificationsEnabled =
        _prefs.getBool('notifications_enabled') ?? true;
    final emailNotificationsEnabled =
        _prefs.getBool('email_notifications_enabled') ?? true;
    final language = _prefs.getString('language') ?? 'es';

    // Crear driver mock (en producción vendría del backend)
    final driver = Driver(
      id: driverId,
      restaurantId: 'mock-restaurant-id',
      name: _prefs.getString('driver_name') ?? 'Juan Pérez',
      email: _prefs.getString('driver_email') ?? 'juan.perez@napoli.com',
      phone: _prefs.getString('driver_phone') ?? '+54 11 1234-5678',
      photoUrl: _prefs.getString('driver_image'),
      vehicleType: _getVehicleType(_prefs.getString('vehicle_type')),
      licensePlate: _prefs.getString('license_plate') ?? 'ABC 123',
      status: DriverStatus.active,
      isOnline: _prefs.getBool('is_online') ?? false,
      isOnDelivery: false,
      createdAt: DateTime.parse(
        _prefs.getString('created_at') ?? DateTime.now().toString(),
      ),
      totalDeliveries: _prefs.getInt('total_deliveries') ?? 156,
      averageRating: _prefs.getDouble('rating') ?? 4.8,
      totalEarningsCents: (_prefs.getDouble('total_earnings') ?? 12450.50 * 100)
          .toInt(),
    );

    return DriverProfile(
      driver: driver,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      language: language,
      appVersion: '1.0.0',
    );
  }

  /// Actualiza la información del conductor
  Future<Driver> updateDriver(Driver driver) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Guardar en SharedPreferences
    await _prefs.setString('driver_name', driver.name);
    await _prefs.setString('driver_phone', driver.phone);
    await _prefs.setString('license_plate', driver.licensePlate);
    await _prefs.setString('vehicle_type', driver.vehicleType.name);
    if (driver.photoUrl != null) {
      await _prefs.setString('driver_image', driver.photoUrl!);
    }

    return driver;
  }

  /// Cambia la contraseña del conductor
  Future<void> changePassword(
    String driverId,
    String oldPassword,
    String newPassword,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));

    // Validar contraseña antigua (mock)
    final storedPassword = _prefs.getString('password') ?? 'password123';
    if (oldPassword != storedPassword) {
      throw Exception('Contraseña actual incorrecta');
    }

    // Guardar nueva contraseña
    await _prefs.setString('password', newPassword);
  }

  /// Actualiza las configuraciones
  Future<DriverProfile> updateSettings(
    String driverId,
    Map<String, dynamic> settings,
  ) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    // Actualizar configuraciones
    if (settings.containsKey('notificationsEnabled')) {
      await _prefs.setBool(
        'notifications_enabled',
        settings['notificationsEnabled'] as bool,
      );
    }
    if (settings.containsKey('emailNotificationsEnabled')) {
      await _prefs.setBool(
        'email_notifications_enabled',
        settings['emailNotificationsEnabled'] as bool,
      );
    }
    if (settings.containsKey('language')) {
      await _prefs.setString('language', settings['language'] as String);
    }

    // Retornar perfil actualizado
    return getProfile(driverId);
  }

  VehicleType _getVehicleType(String? type) {
    switch (type) {
      case 'moto':
        return VehicleType.moto;
      case 'auto':
        return VehicleType.auto;
      case 'bici':
        return VehicleType.bici;
      default:
        return VehicleType.moto;
    }
  }
}
