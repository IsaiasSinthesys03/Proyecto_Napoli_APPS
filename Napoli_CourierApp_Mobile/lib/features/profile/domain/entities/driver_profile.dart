import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/driver.dart';

/// Entidad de dominio que representa el perfil completo de un conductor
/// Extiende Driver con información adicional de configuración
class DriverProfile extends Equatable {
  final Driver driver;
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;
  final String language;
  final String appVersion;

  const DriverProfile({
    required this.driver,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.language = 'es',
    this.appVersion = '1.0.0',
  });

  /// Copia la entidad con campos modificados
  DriverProfile copyWith({
    Driver? driver,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    String? language,
    String? appVersion,
  }) {
    return DriverProfile(
      driver: driver ?? this.driver,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  List<Object?> get props => [
    driver,
    notificationsEnabled,
    emailNotificationsEnabled,
    language,
    appVersion,
  ];
}
