import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/driver.dart';

/// Estados del DashboardCubit
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Estado cargado con datos del driver
class DashboardLoaded extends DashboardState {
  final Driver driver;
  final bool isOnline;

  const DashboardLoaded({required this.driver, required this.isOnline});

  @override
  List<Object?> get props => [driver, isOnline];

  DashboardLoaded copyWith({Driver? driver, bool? isOnline}) {
    return DashboardLoaded(
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

/// Estado de error
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
