import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/driver.dart';
import '../../../auth/domain/entities/vehicle_type.dart';
import '../../../auth/domain/entities/driver_status.dart';
import '../../domain/entities/driver_profile.dart';

/// Remote data source para perfil de driver usando Supabase
class ProfileRemoteDataSource {
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  ProfileRemoteDataSource(this._client, this._prefs);

  /// Obtiene el perfil del conductor desde Supabase
  Future<DriverProfile> getProfile(String driverId) async {
    try {
      print('🔍 DEBUG - Getting profile for driver: $driverId');

      // Llamar a stored procedure get_driver_profile
      final response = await _client.rpc(
        'get_driver_profile',
        params: {'p_driver_id': driverId},
      );

      print('✅ Profile data received: $response');

      // Parse driver data
      final driver = _driverFromJson(response as Map<String, dynamic>);

      // Obtener configuraciones (ahora vienen de la BD)
      final notificationsEnabled =
          response['notifications_enabled'] as bool? ?? true;
      final emailNotificationsEnabled =
          response['email_notifications_enabled'] as bool? ?? true;
      final language = response['preferred_language'] as String? ?? 'es';

      return DriverProfile(
        driver: driver,
        notificationsEnabled: notificationsEnabled,
        emailNotificationsEnabled: emailNotificationsEnabled,
        language: language,
        appVersion: '1.0.0',
      );
    } catch (e) {
      print('❌ Error getting profile: $e');
      throw Exception('Error al obtener perfil: $e');
    }
  }

  /// Actualiza la información del conductor en Supabase
  Future<Driver> updateDriver(Driver driver) async {
    try {
      print('🔍 DEBUG - Updating driver: ${driver.id}');

      // Llamar a stored procedure update_driver_profile
      final response = await _client.rpc(
        'update_driver_profile',
        params: {
          'p_driver_id': driver.id,
          'p_name': driver.name,
          'p_phone': driver.phone,
          'p_vehicle_type': driver.vehicleType.name,
          'p_license_plate': driver.licensePlate,
          'p_photo_url': driver.photoUrl,
        },
      );

      print('✅ Driver updated successfully');

      return _driverFromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('❌ Error updating driver: $e');
      throw Exception('Error al actualizar conductor: $e');
    }
  }

  /// Sube foto de perfil a Supabase Storage
  Future<String> uploadProfilePhoto(String driverId, File photo) async {
    try {
      print('🔍 DEBUG - Uploading profile photo for driver: $driverId');

      final fileName = '$driverId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Subir archivo a Storage
      await _client.storage.from('driver-photos').upload(fileName, photo);

      // Obtener URL pública
      final photoUrl = _client.storage
          .from('driver-photos')
          .getPublicUrl(fileName);

      print('✅ Photo uploaded: $photoUrl');

      // Actualizar URL en drivers table
      await _client.rpc(
        'update_driver_profile',
        params: {'p_driver_id': driverId, 'p_photo_url': photoUrl},
      );

      print('✅ Photo URL updated in database');

      return photoUrl;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      throw Exception('Error al subir foto: $e');
    }
  }

  /// Cambia la contraseña del conductor usando Supabase Auth
  Future<void> changePassword(
    String driverId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      print('🔍 DEBUG - Changing password for driver: $driverId');

      // Usar Supabase Auth para cambiar contraseña
      await _client.auth.updateUser(UserAttributes(password: newPassword));

      print('✅ Password changed successfully');
    } catch (e) {
      print('❌ Error changing password: $e');
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  /// Actualiza las configuraciones (ahora se guardan en la BD)
  Future<DriverProfile> updateSettings(
    String driverId,
    Map<String, dynamic> settings,
  ) async {
    try {
      print('🔍 DEBUG - Updating settings for driver: $driverId');

      // Actualizar configuraciones en la BD
      await _client.rpc(
        'update_driver_profile',
        params: {
          'p_driver_id': driverId,
          'p_notifications_enabled': settings['notificationsEnabled'],
          'p_email_notifications_enabled':
              settings['emailNotificationsEnabled'],
          'p_preferred_language': settings['language'],
        },
      );

      print('✅ Settings updated successfully');

      // Retornar perfil actualizado
      return getProfile(driverId);
    } catch (e) {
      print('❌ Error updating settings: $e');
      throw Exception('Error al actualizar configuraciones: $e');
    }
  }

  /// Helper: Parse JSON to Driver entity
  Driver _driverFromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      photoUrl: json['photo_url'] as String?,
      vehicleType: _parseVehicleType(json['vehicle_type'] as String),
      licensePlate: json['license_plate'] as String? ?? '',
      status: _parseDriverStatus(json['status'] as String),
      isOnline: json['is_online'] as bool? ?? false,
      isOnDelivery: json['is_on_delivery'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      averageRating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalEarningsCents: json['total_earnings_cents'] as int? ?? 0,
    );
  }

  /// Helper: Parse vehicle type string to enum
  VehicleType _parseVehicleType(String type) {
    switch (type.toLowerCase()) {
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

  /// Helper: Parse driver status string to enum
  DriverStatus _parseDriverStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return DriverStatus.pending;
      case 'approved':
        return DriverStatus.approved;
      case 'active':
        return DriverStatus.active;
      case 'inactive':
        return DriverStatus.inactive;
      default:
        return DriverStatus.active;
    }
  }
}
