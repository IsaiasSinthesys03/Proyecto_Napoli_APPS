import 'package:equatable/equatable.dart';

/// Estadísticas del repartidor para el dashboard
class DriverStats extends Equatable {
  final int todayDeliveries;
  final int totalDeliveries;
  final double todayEarnings;
  final double totalEarnings;
  final double rating;

  const DriverStats({
    required this.todayDeliveries,
    required this.totalDeliveries,
    required this.todayEarnings,
    required this.totalEarnings,
    required this.rating,
  });

  @override
  List<Object?> get props => [
    todayDeliveries,
    totalDeliveries,
    todayEarnings,
    totalEarnings,
    rating,
  ];
}
