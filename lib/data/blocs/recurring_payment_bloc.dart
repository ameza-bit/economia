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
    on<ToggleRecurringPaymentDatePaidStatusEvent>(_onTogglePaidStatus);
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

  void _onTogglePaidStatus(
    ToggleRecurringPaymentDatePaidStatusEvent event,
    Emitter<RecurringPaymentState> emit,
  ) async {
    try {
      emit(LoadingRecurringPaymentState());

      // Obtener todos los pagos recurrentes
      final payments = repository.getRecurringPaymentsLocal();

      // Encontrar el pago específico
      final paymentIndex = payments.indexWhere((p) => p.id == event.paymentId);

      if (paymentIndex >= 0) {
        // Obtener el pago
        final payment = payments[paymentIndex];

        // Crear una versión actualizada con el estado cambiado
        final updatedPayment = payment.togglePaidStatus(event.paymentDate);

        // Actualizar en la lista
        payments[paymentIndex] = updatedPayment;

        // Guardar la lista actualizada
        repository.saveRecurringPaymentsLocal(payments);

        // Actualizar _payments para mantener el estado interno actualizado
        _payments = payments;
      }

      emit(LoadedRecurringPaymentState(_payments));
    } catch (e) {
      emit(
        ErrorRecurringPaymentState(
          "Error al actualizar el estado de pago recurrente: $e",
        ),
      );
    }
  }
}
