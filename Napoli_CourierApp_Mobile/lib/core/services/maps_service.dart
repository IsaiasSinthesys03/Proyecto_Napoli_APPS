import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para manejar la apertura de Google Maps
class MapsService {
  /// Abre Google Maps con una dirección específica
  ///
  /// [address]: La dirección a buscar en Google Maps
  /// Retorna true si se abrió exitosamente, false en caso contrario
  static Future<bool> openMapWithAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final mapsUrl = 'https://www.google.com/maps/search/$encodedAddress';

      debugPrint('🗺️ Abriendo Google Maps: $address');

      final uri = Uri.parse(mapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ Google Maps abierto exitosamente');
        return true;
      } else {
        debugPrint('❌ No se puede abrir Google Maps');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al abrir Google Maps: $e');
      return false;
    }
  }

  /// Abre Google Maps con coordenadas (latitud y longitud)
  ///
  /// [latitude]: Latitud de la ubicación
  /// [longitude]: Longitud de la ubicación
  /// [label]: Etiqueta opcional para mostrar en el marcador
  /// Retorna true si se abrió exitosamente, false en caso contrario
  static Future<bool> openMapWithCoordinates(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      final mapsUrl = label != null && label.isNotEmpty
          ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label'
          : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      debugPrint(
        '🗺️ Abriendo Google Maps con coordenadas: $latitude, $longitude',
      );

      final uri = Uri.parse(mapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ Google Maps abierto exitosamente');
        return true;
      } else {
        debugPrint('❌ No se puede abrir Google Maps');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error al abrir Google Maps: $e');
      return false;
    }
  }
}
