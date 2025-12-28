import 'package:equatable/equatable.dart';
import 'vehicle_type.dart';
import 'driver_status.dart';

/// Entidad de dominio que representa a un repartidor
class Driver extends Equatable {
  final String id;
  final String restaurantId;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final VehicleType vehicleType;
  final String licensePlate;
  final DriverStatus status;
  final bool isOnline;
  final bool isOnDelivery;
  final DateTime createdAt;

  // Estadísticas
  final int totalDeliveries;
  final double averageRating;
  final int totalEarningsCents;

  const Driver({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.vehicleType,
    required this.licensePlate,
    required this.status,
    required this.isOnline,
    required this.isOnDelivery,
    required this.createdAt,
    this.totalDeliveries = 0,
    this.averageRating = 0.0,
    this.totalEarningsCents = 0,
  });

  /// Verifica si el repartidor puede iniciar sesión
  bool get canLogin => status.canLogin;

  /// Verifica si el repartidor está pendiente de aprobación
  bool get isPending => status == DriverStatus.pending;

  /// Copia la entidad con campos modificados
  Driver copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    VehicleType? vehicleType,
    String? licensePlate,
    DriverStatus? status,
    bool? isOnline,
    bool? isOnDelivery,
    DateTime? createdAt,
    int? totalDeliveries,
    double? averageRating,
    int? totalEarningsCents,
  }) {
    return Driver(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      licensePlate: licensePlate ?? this.licensePlate,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isOnDelivery: isOnDelivery ?? this.isOnDelivery,
      createdAt: createdAt ?? this.createdAt,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      averageRating: averageRating ?? this.averageRating,
      totalEarningsCents: totalEarningsCents ?? this.totalEarningsCents,
    );
  }

  @override
  List<Object?> get props => [
    id,
    restaurantId,
    name,
    email,
    phone,
    photoUrl,
    vehicleType,
    licensePlate,
    status,
    isOnline,
    isOnDelivery,
    createdAt,
    totalDeliveries,
    averageRating,
    totalEarningsCents,
  ];
}
