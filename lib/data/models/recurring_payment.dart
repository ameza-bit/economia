import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/enums/week_day.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:intl/intl.dart' show NumberFormat;

class RecurringPayment {
  final String id;
  final String name;
  final String description;
  final String provider;
  final double amount;
  final FinancialCard? card;
  final RecurrenceType recurrenceType;
  final PaymentDateType paymentDateType;
  final int specificDay; // Primer día específico
  final int? secondSpecificDay; // Segundo día específico para pagos quincenales
  final WeekDay? weekDay;
  final int weekDayOrdinal;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String category;
  final DateTime nextPaymentDate;
  final List<DateTime> manuallyMarkedPayments;

  RecurringPayment({
    required this.id,
    required this.name,
    this.description = '',
    required this.provider,
    required this.amount,
    this.card,
    required this.recurrenceType,
    required this.paymentDateType,
    this.specificDay = 1,
    this.secondSpecificDay, // Nuevo campo para el segundo día
    this.weekDay,
    this.weekDayOrdinal = 1,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.category = 'General',
    DateTime? nextPaymentDate,
    this.manuallyMarkedPayments = const [],
  }) : nextPaymentDate = nextPaymentDate ?? startDate;

  factory RecurringPayment.fromJson(Map<String, dynamic> json) {
    return RecurringPayment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      provider: json['provider'] ?? '',
      amount: json['amount'] ?? 0.0,
      card: json['card'] != null ? FinancialCard.fromJson(json['card']) : null,
      recurrenceType: RecurrenceType.values[json['recurrenceType'] ?? 3],
      paymentDateType: PaymentDateType.values[json['paymentDateType'] ?? 0],
      specificDay: json['specificDay'] ?? 1,
      secondSpecificDay: json['secondSpecificDay'], // Añadir este campo
      weekDay: json['weekDay'] != null ? WeekDay.values[json['weekDay']] : null,
      weekDayOrdinal: json['weekDayOrdinal'] ?? 1,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      category: json['category'] ?? 'General',
      nextPaymentDate:
          DateTime.tryParse(json['nextPaymentDate'] ?? '') ?? DateTime.now(),
      manuallyMarkedPayments:
          (json['manuallyMarkedPayments'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e.toString()))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'provider': provider,
    'amount': amount,
    'card': card?.toJson(),
    'recurrenceType': recurrenceType.index,
    'paymentDateType': paymentDateType.index,
    'specificDay': specificDay,
    'secondSpecificDay': secondSpecificDay, // Añadir este campo
    'weekDay': weekDay?.index,
    'weekDayOrdinal': weekDayOrdinal,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isActive': isActive,
    'category': category,
    'nextPaymentDate': nextPaymentDate.toIso8601String(),
    'manuallyMarkedPayments':
        manuallyMarkedPayments.map((e) => e.toIso8601String()).toList(),
  };

  // Copia con posibilidad de modificar valores
  RecurringPayment copyWith({
    String? id,
    String? name,
    String? description,
    String? provider,
    double? amount,
    FinancialCard? card,
    RecurrenceType? recurrenceType,
    PaymentDateType? paymentDateType,
    int? specificDay,
    int? secondSpecificDay,
    WeekDay? weekDay,
    int? weekDayOrdinal,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? category,
    DateTime? nextPaymentDate,
    List<DateTime>? manuallyMarkedPayments,
  }) {
    return RecurringPayment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      card: card ?? this.card,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      paymentDateType: paymentDateType ?? this.paymentDateType,
      specificDay: specificDay ?? this.specificDay,
      secondSpecificDay:
          secondSpecificDay ?? this.secondSpecificDay, // Actualizar
      weekDay: weekDay ?? this.weekDay,
      weekDayOrdinal: weekDayOrdinal ?? this.weekDayOrdinal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      manuallyMarkedPayments:
          manuallyMarkedPayments ?? this.manuallyMarkedPayments,
    );
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return formatter.format(amount);
  }

  String getPaymentDateDescription() {
    switch (paymentDateType) {
      case PaymentDateType.specificDay:
        if (recurrenceType == RecurrenceType.biweekly &&
            secondSpecificDay != null) {
          return 'Días $specificDay y $secondSpecificDay de cada mes';
        }
        return 'Día $specificDay de cada ${_getRecurrencePeriod()}';
      case PaymentDateType.weekDay:
        return '${_getOrdinalText()} ${weekDay?.displayName ?? "día"} de cada ${_getRecurrencePeriod()}';
      case PaymentDateType.lastDayOfMonth:
        return 'Último día de cada ${_getRecurrencePeriod()}';
    }
  }

  String _getRecurrencePeriod() {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return 'día';
      case RecurrenceType.weekly:
        return 'semana';
      case RecurrenceType.biweekly:
        return 'quincena';
      case RecurrenceType.monthly:
        return 'mes';
      case RecurrenceType.bimonthly:
        return 'bimestre';
      case RecurrenceType.quarterly:
        return 'trimestre';
      case RecurrenceType.semiannual:
        return 'semestre';
      case RecurrenceType.annual:
        return 'año';
      case RecurrenceType.custom:
        return 'periodo personalizado';
    }
  }

  String _getOrdinalText() {
    if (weekDayOrdinal == -1) return 'Último';

    switch (weekDayOrdinal) {
      case 1:
        return 'Primer';
      case 2:
        return 'Segundo';
      case 3:
        return 'Tercer';
      case 4:
        return 'Cuarto';
      case 5:
        return 'Quinto';
      default:
        return '$weekDayOrdinal°';
    }
  }

  // Método para verificar si una fecha específica está marcada como pagada
  bool isDateMarkedAsPaid(DateTime date) {
    // Compara solo año, mes y día, ignorando horas y minutos
    return manuallyMarkedPayments.any(
      (markedDate) =>
          markedDate.year == date.year &&
          markedDate.month == date.month &&
          markedDate.day == date.day,
    );
  }

  // Método para alternar el estado pagado/no pagado de una fecha específica
  RecurringPayment togglePaidStatus(DateTime date) {
    // Normalizar la fecha (solo año, mes, día)
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Crear una copia de la lista de pagos marcados
    final updatedMarkedPayments = List<DateTime>.from(manuallyMarkedPayments);

    // Verificar si la fecha ya está marcada
    final existingIndex = updatedMarkedPayments.indexWhere(
      (markedDate) =>
          markedDate.year == normalizedDate.year &&
          markedDate.month == normalizedDate.month &&
          markedDate.day == normalizedDate.day,
    );

    // Si está marcada, desmarcar; si no, marcar
    if (existingIndex >= 0) {
      updatedMarkedPayments.removeAt(existingIndex);
    } else {
      updatedMarkedPayments.add(normalizedDate);
    }

    // Retornar una nueva instancia con la lista actualizada
    return copyWith(manuallyMarkedPayments: updatedMarkedPayments);
  }
}
