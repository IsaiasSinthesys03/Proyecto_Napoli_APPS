import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Servicio para realizar llamadas telefónicas
class PhoneService {
  /// Realiza una llamada al número especificado
  Future<bool> call(String phoneNumber) async {
    debugPrint('📞 PhoneService.call called with: $phoneNumber');

    // Limpiar el número: remover espacios, guiones, paréntesis, etc.
    var cleanNumber = phoneNumber.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    ); // Remover todo excepto dígitos y +

    debugPrint('📞 Cleaned number after removing special chars: $cleanNumber');

    // Si el número no empieza con +, agregamos +52 (Código de país México)
    // Esto también asegura que si el número viene vacío, al menos se abra el dialer con +52
    if (!cleanNumber.startsWith('+')) {
      cleanNumber = '+52$cleanNumber';
    }

    debugPrint('📞 Final number for URI: $cleanNumber');

    final uri = Uri(scheme: 'tel', path: cleanNumber);
    debugPrint('📞 Dialing URI: $uri');

    try {
      if (await canLaunchUrl(uri)) {
        debugPrint('📞 Can launch URL, launching...');
        final result = await launchUrl(uri);
        debugPrint('📞 Launch result: $result');
        return result;
      } else {
        debugPrint('❌ Cannot launch URL: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error during phone call: $e');
      return false;
    }
  }
}
