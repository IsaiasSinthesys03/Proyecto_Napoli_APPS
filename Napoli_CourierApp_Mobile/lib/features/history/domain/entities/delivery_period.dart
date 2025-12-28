/// Período de tiempo para filtrar el historial de entregas
enum DeliveryPeriod {
  today('Hoy'),
  week('Semana'),
  month('Mes');

  final String displayName;
  const DeliveryPeriod(this.displayName);
}
