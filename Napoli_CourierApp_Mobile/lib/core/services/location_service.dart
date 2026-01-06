import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// Servicio para obtener la ubicación del dispositivo
class LocationService {
  /// Solicita permisos y obtiene la ubicación actual.
  /// Retorna un [Position] con lat/lon o lanza excepción en error.
  static Future<Position> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      debugPrint('📍 LocationService position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ LocationService error: $e');
      rethrow;
    }
  }
}
