// lib/data/blocs/recurring_payment_bloc.dart
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/data/states/recurring_payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringPaymentBloc
    extends Bloc<RecurringPaymentEvent, RecurringPaymentState> {
  final RecurringPaymentRepository repository;
  List<RecurringPayment> _payments = [];

  RecurringPaymentBloc({required this.repository})
    : super(InitialRecurringPaymentState()) {
    on<LoadRecurringPaymentEvent>(_onLoadPayments);
    on<RefreshRecurringPaymentEvent>(_onRefreshPayments);
    on<FilterRecurringPaymentByMonthEvent>(_onFilterByMonth);
  }

  void _onLoadPayments(
    LoadRecurringPaymentEvent event,
    Emitter<RecurringPaymentState> emit,
  ) async {
    try {
      emit(LoadingRecurringPaymentState());
      _payments = repository.getRecurringPaymentsLocal();
      emit(LoadedRecurringPaymentState(_payments));
    } catch (e) {
      emit(ErrorRecurringPaymentState("Error cargando pagos recurrentes: $e"));
    }
  }

  void _onRefreshPayments(
    RefreshRecurringPaymentEvent event,
    Emitter<RecurringPaymentState> emit,
  ) async {
    try {
      emit(LoadingRecurringPaymentState());
      _payments = repository.getRecurringPaymentsLocal();
      emit(LoadedRecurringPaymentState(_payments));
    } catch (e) {
      emit(ErrorRecurringPaymentState("Error cargando pagos recurrentes: $e"));
    }
  }

  void _onFilterByMonth(
    FilterRecurringPaymentByMonthEvent event,
    Emitter<RecurringPaymentState> emit,
  ) async {
    try {
      emit(LoadingRecurringPaymentState());
      final filteredPayments = repository.getRecurringPaymentsByMonth(
        event.year,
        event.month,
      );
      emit(LoadedRecurringPaymentState(filteredPayments));
    } catch (e) {
      emit(ErrorRecurringPaymentState("Error filtrando pagos recurrentes: $e"));
    }
  }
}
