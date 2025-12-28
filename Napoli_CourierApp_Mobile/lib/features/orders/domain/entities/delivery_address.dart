import 'package:equatable/equatable.dart';

/// Dirección de entrega con coordenadas GPS
class DeliveryAddress extends Equatable {
  final String street;
  final String? details; // Piso, depto, etc.
  final String? notes; // Instrucciones especiales
  final double latitude;
  final double longitude;

  const DeliveryAddress({
    required this.street,
    this.details,
    this.notes,
    required this.latitude,
    required this.longitude,
  });

  /// Dirección completa formateada
  String get fullAddress {
    final parts = [street];
    if (details != null && details!.isNotEmpty) {
      parts.add(details!);
    }
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, details, notes, latitude, longitude];
}
