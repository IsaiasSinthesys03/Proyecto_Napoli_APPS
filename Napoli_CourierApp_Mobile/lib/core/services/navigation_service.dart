import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Servicio para abrir navegación GPS
class NavigationService {
  /// Abre Google Maps o Waze para navegar a las coordenadas
  Future<bool> openMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    print('🗺️ NavigationService.openMaps called');
    print('🗺️ Lat: $latitude, Lng: $longitude, Label: $label');

    // Intentar abrir Waze primero (preferido por repartidores)
    print('🗺️ Trying Waze...');
    if (await _openWaze(latitude, longitude)) {
      print('🗺️ Waze opened successfully');
      return true;
    }

    // Si Waze no está disponible, abrir Google Maps
    print('🗺️ Waze not available, trying Google Maps...');
    final result = await _openGoogleMaps(latitude, longitude, label);
    print('🗺️ Google Maps result: $result');
    return result;
  }

  /// Intenta abrir Waze
  Future<bool> _openWaze(double latitude, double longitude) async {
    final wazeUrl = Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes');
    print('🗺️ Waze URL: $wazeUrl');

    if (await canLaunchUrl(wazeUrl)) {
      print('🗺️ Can launch Waze, launching...');
      final result = await launchUrl(wazeUrl);
      print('🗺️ Waze launch result: $result');
      return result;
    }
    print('🗺️ Cannot launch Waze');
    return false;
  }

  /// Abre Google Maps
  Future<bool> _openGoogleMaps(
    double latitude,
    double longitude,
    String? label,
  ) async {
    Uri googleMapsUrl;

    if (Platform.isIOS) {
      // iOS usa comgooglemaps:// o http://maps.apple.com
      googleMapsUrl = Uri.parse(
        'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl);
      }

      // Fallback a Apple Maps
      googleMapsUrl = Uri.parse(
        'http://maps.apple.com/?daddr=$latitude,$longitude',
      );
    } else {
      // Android usa geo: o https://maps.google.com
      googleMapsUrl = Uri.parse('google.navigation:q=$latitude,$longitude');

      if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl);
      }

      // Fallback a web
      googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );
    }

    if (await canLaunchUrl(googleMapsUrl)) {
      return await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }
}
