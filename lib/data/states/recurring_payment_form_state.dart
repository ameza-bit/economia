import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/enums/week_day.dart';
import 'package:economia/data/models/financial_card.dart';

sealed class RecurringPaymentFormState {}

class RecurringPaymentFormInitialState extends RecurringPaymentFormState {}

class RecurringPaymentFormLoadingState extends RecurringPaymentFormState {}

class RecurringPaymentFormSuccessState extends RecurringPaymentFormState {
  final String message;
  RecurringPaymentFormSuccessState(this.message);
}

class RecurringPaymentFormErrorState extends RecurringPaymentFormState {
  final String message;
  RecurringPaymentFormErrorState(this.message);
}

class RecurringPaymentFormReadyState extends RecurringPaymentFormState {
  final String name;
  final String description;
  final String provider;
  final String amount;
  final FinancialCard? selectedCard;
  final RecurrenceType recurrenceType;
  final PaymentDateType paymentDateType;
  final int specificDay;
  final WeekDay? weekDay;
  final int weekDayOrdinal;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String category;

  RecurringPaymentFormReadyState({
    this.name = '',
    this.description = '',
    this.provider = '',
    this.amount = '',
    this.selectedCard,
    this.recurrenceType = RecurrenceType.monthly,
    this.paymentDateType = PaymentDateType.specificDay,
    this.specificDay = 1,
    this.weekDay = WeekDay.monday,
    this.weekDayOrdinal = 1,
    DateTime? startDate,
    this.endDate,
    this.isActive = true,
    this.category = 'General',
  }) : startDate = startDate ?? DateTime.now();

  RecurringPaymentFormReadyState copyWith({
    String? name,
    String? description,
    String? provider,
    String? amount,
    FinancialCard? selectedCard,
    RecurrenceType? recurrenceType,
    PaymentDateType? paymentDateType,
    int? specificDay,
    WeekDay? weekDay,
    int? weekDayOrdinal,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? category,
  }) {
    return RecurringPaymentFormReadyState(
      name: name ?? this.name,
      description: description ?? this.description,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      selectedCard: selectedCard ?? this.selectedCard,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      paymentDateType: paymentDateType ?? this.paymentDateType,
      specificDay: specificDay ?? this.specificDay,
      weekDay: weekDay ?? this.weekDay,
      weekDayOrdinal: weekDayOrdinal ?? this.weekDayOrdinal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }
}
