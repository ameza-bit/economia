import 'package:flutter/material.dart' show Colors, Color;

enum RecurrenceType {
  daily, // Diario
  weekly, // Semanal
  biweekly, // Quincenal
  monthly, // Mensual
  bimonthly, // Bimestral
  quarterly, // Trimestral
  semiannual, // Semestral
  annual, // Anual
  custom, // Personalizado
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Diario';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.biweekly:
        return 'Quincenal';
      case RecurrenceType.monthly:
        return 'Mensual';
      case RecurrenceType.bimonthly:
        return 'Bimestral';
      case RecurrenceType.quarterly:
        return 'Trimestral';
      case RecurrenceType.semiannual:
        return 'Semestral';
      case RecurrenceType.annual:
        return 'Anual';
      case RecurrenceType.custom:
        return 'Personalizado';
    }
  }

  int get months {
    switch (this) {
      case RecurrenceType.daily:
      case RecurrenceType.weekly:
      case RecurrenceType.biweekly:
      case RecurrenceType.monthly:
        return 1;
      case RecurrenceType.bimonthly:
        return 2;
      case RecurrenceType.quarterly:
        return 3;
      case RecurrenceType.semiannual:
        return 6;
      case RecurrenceType.annual:
        return 12;
      case RecurrenceType.custom:
        return 1; // Valor predeterminado, se debe ajustar según sea necesario
    }
  }

  Color get color {
    switch (this) {
      case RecurrenceType.daily:
        return Colors.blue.shade100;
      case RecurrenceType.weekly:
        return Colors.green.shade100;
      case RecurrenceType.biweekly:
        return Colors.purple.shade100;
      case RecurrenceType.monthly:
        return Colors.amber.shade100;
      case RecurrenceType.bimonthly:
        return Colors.teal.shade100;
      case RecurrenceType.quarterly:
        return Colors.indigo.shade100;
      case RecurrenceType.semiannual:
        return Colors.deepOrange.shade100;
      case RecurrenceType.annual:
        return Colors.red.shade100;
      case RecurrenceType.custom:
        return Colors.grey.shade100;
    }
  }
}
