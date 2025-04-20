import 'package:economia/data/models/recurring_payment.dart';

sealed class RecurringPaymentState {}

class InitialRecurringPaymentState extends RecurringPaymentState {}

class LoadingRecurringPaymentState extends RecurringPaymentState {}

class LoadedRecurringPaymentState extends RecurringPaymentState {
  final List<RecurringPayment> payments;
  LoadedRecurringPaymentState(this.payments);
}

class ErrorRecurringPaymentState extends RecurringPaymentState {
  final String message;
  ErrorRecurringPaymentState(this.message);
}
