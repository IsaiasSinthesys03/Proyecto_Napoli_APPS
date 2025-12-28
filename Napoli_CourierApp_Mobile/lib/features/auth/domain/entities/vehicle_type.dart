/// Tipos de vehículo disponibles para repartidores
enum VehicleType {
  moto,
  bici,
  auto;

  String get displayName {
    switch (this) {
      case VehicleType.moto:
        return 'Moto';
      case VehicleType.bici:
        return 'Bicicleta';
      case VehicleType.auto:
        return 'Auto';
    }
  }
}
