enum PaymentDateType {
  specificDay, // Día específico del mes (ej. día 15)
  weekDay, // Día de la semana (ej. tercer martes)
  lastDayOfMonth, // Último día del mes
}

extension PaymentDateTypeExtension on PaymentDateType {
  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case PaymentDateType.specificDay:
        return 'Día específico';
      case PaymentDateType.weekDay:
        return 'Día de la semana';
      case PaymentDateType.lastDayOfMonth:
        return 'Último día del mes';
    }
  }
}
