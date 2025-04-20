import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/enums/week_day.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:flutter/material.dart' show BuildContext;

sealed class RecurringPaymentFormEvent {}

class RecurringPaymentFormInitEvent extends RecurringPaymentFormEvent {}

class RecurringPaymentFormUpdateNameEvent extends RecurringPaymentFormEvent {
  final String name;
  RecurringPaymentFormUpdateNameEvent(this.name);
}

class RecurringPaymentFormUpdateDescriptionEvent
    extends RecurringPaymentFormEvent {
  final String description;
  RecurringPaymentFormUpdateDescriptionEvent(this.description);
}

class RecurringPaymentFormUpdateProviderEvent
    extends RecurringPaymentFormEvent {
  final String provider;
  RecurringPaymentFormUpdateProviderEvent(this.provider);
}

class RecurringPaymentFormUpdateAmountEvent extends RecurringPaymentFormEvent {
  final String amount;
  RecurringPaymentFormUpdateAmountEvent(this.amount);
}

class RecurringPaymentFormUpdateSelectedCardEvent
    extends RecurringPaymentFormEvent {
  final FinancialCard? card;
  RecurringPaymentFormUpdateSelectedCardEvent(this.card);
}

class RecurringPaymentFormUpdateRecurrenceTypeEvent
    extends RecurringPaymentFormEvent {
  final RecurrenceType recurrenceType;
  RecurringPaymentFormUpdateRecurrenceTypeEvent(this.recurrenceType);
}

class RecurringPaymentFormUpdatePaymentDateTypeEvent
    extends RecurringPaymentFormEvent {
  final PaymentDateType paymentDateType;
  RecurringPaymentFormUpdatePaymentDateTypeEvent(this.paymentDateType);
}

class RecurringPaymentFormUpdateSpecificDayEvent
    extends RecurringPaymentFormEvent {
  final int day;
  RecurringPaymentFormUpdateSpecificDayEvent(this.day);
}

class RecurringPaymentFormUpdateSecondSpecificDayEvent
    extends RecurringPaymentFormEvent {
  final int? day;
  RecurringPaymentFormUpdateSecondSpecificDayEvent(this.day);
}

class RecurringPaymentFormUpdateWeekDayEvent extends RecurringPaymentFormEvent {
  final WeekDay weekDay;
  RecurringPaymentFormUpdateWeekDayEvent(this.weekDay);
}

class RecurringPaymentFormUpdateWeekDayOrdinalEvent
    extends RecurringPaymentFormEvent {
  final int ordinal;
  RecurringPaymentFormUpdateWeekDayOrdinalEvent(this.ordinal);
}

class RecurringPaymentFormUpdateStartDateEvent
    extends RecurringPaymentFormEvent {
  final DateTime startDate;
  RecurringPaymentFormUpdateStartDateEvent(this.startDate);
}

class RecurringPaymentFormUpdateEndDateEvent extends RecurringPaymentFormEvent {
  final DateTime? endDate;
  RecurringPaymentFormUpdateEndDateEvent(this.endDate);
}

class RecurringPaymentFormUpdateIsActiveEvent
    extends RecurringPaymentFormEvent {
  final bool isActive;
  RecurringPaymentFormUpdateIsActiveEvent(this.isActive);
}

class RecurringPaymentFormUpdateCategoryEvent
    extends RecurringPaymentFormEvent {
  final String category;
  RecurringPaymentFormUpdateCategoryEvent(this.category);
}

class RecurringPaymentFormLoadExistingPaymentEvent
    extends RecurringPaymentFormEvent {
  final RecurringPayment payment;
  RecurringPaymentFormLoadExistingPaymentEvent(this.payment);
}

class RecurringPaymentFormSaveEvent extends RecurringPaymentFormEvent {
  final BuildContext? context;
  final bool isEditing;
  final String? paymentId;

  RecurringPaymentFormSaveEvent({
    this.context,
    this.isEditing = false,
    this.paymentId,
  });
}

class RecurringPaymentFormDeleteEvent extends RecurringPaymentFormEvent {
  final String paymentId;
  final BuildContext context;

  RecurringPaymentFormDeleteEvent({
    required this.paymentId,
    required this.context,
  });
}
