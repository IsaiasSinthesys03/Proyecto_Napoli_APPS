import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/vehicle_type.dart';
import '../../domain/entities/driver_status.dart';

part 'driver_model.g.dart';

/// Modelo de datos para Driver con serialización JSON
@JsonSerializable()
class DriverModel {
  final String id;
  @JsonKey(name: 'restaurant_id')
  final String restaurantId;
  final String name;
  final String email;
  final String phone;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'vehicle_type')
  final String vehicleType;
  @JsonKey(name: 'license_plate')
  final String licensePlate;
  final String status;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'is_on_delivery')
  final bool isOnDelivery;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'total_deliveries')
  final int totalDeliveries;
  @JsonKey(name: 'rating_sum')
  final int ratingSum;
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @JsonKey(name: 'total_earnings_cents')
  final int totalEarningsCents;

  const DriverModel({
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
    this.ratingSum = 0,
    this.ratingCount = 0,
    this.averageRating,
    this.totalEarningsCents = 0,
  });

  /// Convierte el modelo a entidad de dominio
  Driver toEntity() {
    return Driver(
      id: id,
      restaurantId: restaurantId,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      vehicleType: _parseVehicleType(vehicleType),
      licensePlate: licensePlate,
      status: _parseDriverStatus(status),
      isOnline: isOnline,
      isOnDelivery: isOnDelivery,
      createdAt: DateTime.parse(createdAt),
      totalDeliveries: totalDeliveries,
      averageRating: averageRating ?? 0.0,
      totalEarningsCents: totalEarningsCents,
    );
  }

  /// Formato de earnings en dólares
  String get formattedEarnings =>
      '\$${(totalEarningsCents / 100).toStringAsFixed(2)}';

  /// Crea un modelo desde una entidad de dominio
  factory DriverModel.fromEntity(Driver driver) {
    return DriverModel(
      id: driver.id,
      restaurantId: driver.restaurantId,
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      photoUrl: driver.photoUrl,
      vehicleType: driver.vehicleType.name,
      licensePlate: driver.licensePlate,
      status: driver.status.name,
      isOnline: driver.isOnline,
      isOnDelivery: driver.isOnDelivery,
      createdAt: driver.createdAt.toIso8601String(),
      totalDeliveries: driver.totalDeliveries,
      ratingSum: 0, // No disponible en entity
      ratingCount: 0, // No disponible en entity
      averageRating: driver.averageRating,
      totalEarningsCents: driver.totalEarningsCents,
    );
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverModelToJson(this);

  DriverModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? vehicleType,
    String? licensePlate,
    String? status,
    bool? isOnline,
    bool? isOnDelivery,
    String? createdAt,
    int? totalDeliveries,
    int? ratingSum,
    int? ratingCount,
    double? averageRating,
    int? totalEarningsCents,
  }) {
    return DriverModel(
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
      ratingSum: ratingSum ?? this.ratingSum,
      ratingCount: ratingCount ?? this.ratingCount,
      averageRating: averageRating ?? this.averageRating,
      totalEarningsCents: totalEarningsCents ?? this.totalEarningsCents,
    );
  }

  VehicleType _parseVehicleType(String type) {
    switch (type.toLowerCase()) {
      case 'moto':
        return VehicleType.moto;
      case 'bici':
      case 'bicicleta':
        return VehicleType.bici;
      case 'auto':
        return VehicleType.auto;
      default:
        return VehicleType.moto;
    }
  }

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
        return DriverStatus.pending;
    }
  }
}
