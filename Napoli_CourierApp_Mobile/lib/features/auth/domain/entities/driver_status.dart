/// Estados posibles de un repartidor en el sistema
enum DriverStatus {
  /// Registro enviado, esperando aprobación del administrador
  pending,

  /// Aprobado por administrador, puede iniciar sesión
  approved,

  /// Activo y trabajando
  active,

  /// Inactivo o suspendido
  inactive;

  String get displayName {
    switch (this) {
      case DriverStatus.pending:
        return 'Pendiente de Aprobación';
      case DriverStatus.approved:
        return 'Aprobado';
      case DriverStatus.active:
        return 'Activo';
      case DriverStatus.inactive:
        return 'Inactivo';
    }
  }

  bool get canLogin =>
      this == DriverStatus.approved || this == DriverStatus.active;
}
