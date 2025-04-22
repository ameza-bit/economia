sealed class RecurringPaymentEvent {}

class LoadRecurringPaymentEvent extends RecurringPaymentEvent {}

class RefreshRecurringPaymentEvent extends RecurringPaymentEvent {}

class FilterRecurringPaymentByMonthEvent extends RecurringPaymentEvent {
  final int year;
  final int month;

  FilterRecurringPaymentByMonthEvent(this.year, this.month);
}

class ToggleRecurringPaymentDatePaidStatusEvent extends RecurringPaymentEvent {
  final String paymentId;
  final DateTime paymentDate;

  ToggleRecurringPaymentDatePaidStatusEvent(this.paymentId, this.paymentDate);
}
