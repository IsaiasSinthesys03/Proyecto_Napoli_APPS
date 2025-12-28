import 'package:url_launcher/url_launcher.dart';

/// Servicio para realizar llamadas telefónicas
class PhoneService {
  /// Realiza una llamada al número especificado
  Future<bool> call(String phoneNumber) async {
    print('📞 PhoneService.call called with: $phoneNumber');

    // Limpiar el número (remover espacios, guiones, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    print('📞 Cleaned number: $cleanNumber');

    final uri = Uri(scheme: 'tel', path: cleanNumber);
    print('📞 URI: $uri');

    if (await canLaunchUrl(uri)) {
      print('📞 Can launch URL, launching...');
      final result = await launchUrl(uri);
      print('📞 Launch result: $result');
      return result;
    } else {
      print('❌ Cannot launch URL: $uri');
      return false;
    }
  }
}
