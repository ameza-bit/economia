import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/events/recurring_payment_form_event.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/data/services/recurring_payment_calculator.dart';
import 'package:economia/data/states/recurring_payment_form_state.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringPaymentFormBloc
    extends Bloc<RecurringPaymentFormEvent, RecurringPaymentFormState> {
  final RecurringPaymentRepository recurringPaymentRepository;
  final CardRepository cardRepository;

  RecurringPaymentFormBloc({
    required this.recurringPaymentRepository,
    required this.cardRepository,
  }) : super(RecurringPaymentFormInitialState()) {
    on<RecurringPaymentFormInitEvent>(_onInit);
    on<RecurringPaymentFormUpdateNameEvent>(_onUpdateName);
    on<RecurringPaymentFormUpdateDescriptionEvent>(_onUpdateDescription);
    on<RecurringPaymentFormUpdateProviderEvent>(_onUpdateProvider);
    on<RecurringPaymentFormUpdateAmountEvent>(_onUpdateAmount);
    on<RecurringPaymentFormUpdateSelectedCardEvent>(_onUpdateSelectedCard);
    on<RecurringPaymentFormUpdateRecurrenceTypeEvent>(_onUpdateRecurrenceType);
    on<RecurringPaymentFormUpdatePaymentDateTypeEvent>(
      _onUpdatePaymentDateType,
    );
    on<RecurringPaymentFormUpdateSpecificDayEvent>(_onUpdateSpecificDay);
    on<RecurringPaymentFormUpdateSecondSpecificDayEvent>(
      _onUpdateSecondSpecificDay,
    );
    on<RecurringPaymentFormUpdateWeekDayEvent>(_onUpdateWeekDay);
    on<RecurringPaymentFormUpdateWeekDayOrdinalEvent>(_onUpdateWeekDayOrdinal);
    on<RecurringPaymentFormUpdateStartDateEvent>(_onUpdateStartDate);
    on<RecurringPaymentFormUpdateEndDateEvent>(_onUpdateEndDate);
    on<RecurringPaymentFormUpdateIsActiveEvent>(_onUpdateIsActive);
    on<RecurringPaymentFormUpdateCategoryEvent>(_onUpdateCategory);
    on<RecurringPaymentFormLoadExistingPaymentEvent>(_onLoadExistingPayment);
    on<RecurringPaymentFormSaveEvent>(_onSave);
    on<RecurringPaymentFormDeleteEvent>(_onDelete);
  }

  void _onInit(
    RecurringPaymentFormInitEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    try {
      // Obtener todas las tarjetas disponibles
      final cards = cardRepository.getCardsLocal();

      emit(
        RecurringPaymentFormReadyState(
          // Si hay tarjetas disponibles, seleccionar la primera por defecto
          selectedCard: cards.isNotEmpty ? cards.first : null,
        ),
      );
    } catch (e) {
      emit(RecurringPaymentFormErrorState('Error al inicializar: $e'));
    }
  }

  void _onUpdateName(
    RecurringPaymentFormUpdateNameEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(name: event.name));
    }
  }

  void _onUpdateDescription(
    RecurringPaymentFormUpdateDescriptionEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onUpdateProvider(
    RecurringPaymentFormUpdateProviderEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(provider: event.provider));
    }
  }

  void _onUpdateAmount(
    RecurringPaymentFormUpdateAmountEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(amount: event.amount));
    }
  }

  void _onUpdateSelectedCard(
    RecurringPaymentFormUpdateSelectedCardEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(selectedCard: event.card));
    }
  }

  void _onUpdateRecurrenceType(
    RecurringPaymentFormUpdateRecurrenceTypeEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(recurrenceType: event.recurrenceType));
    }
  }

  void _onUpdatePaymentDateType(
    RecurringPaymentFormUpdatePaymentDateTypeEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(paymentDateType: event.paymentDateType));
    }
  }

  void _onUpdateSpecificDay(
    RecurringPaymentFormUpdateSpecificDayEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(specificDay: event.day));
    }
  }

  void _onUpdateSecondSpecificDay(
    RecurringPaymentFormUpdateSecondSpecificDayEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(secondSpecificDay: event.day));
    }
  }

  void _onUpdateWeekDay(
    RecurringPaymentFormUpdateWeekDayEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(weekDay: event.weekDay));
    }
  }

  void _onUpdateWeekDayOrdinal(
    RecurringPaymentFormUpdateWeekDayOrdinalEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(weekDayOrdinal: event.ordinal));
    }
  }

  void _onUpdateStartDate(
    RecurringPaymentFormUpdateStartDateEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(startDate: event.startDate));
    }
  }

  void _onUpdateEndDate(
    RecurringPaymentFormUpdateEndDateEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.setEndDate(event.endDate));
    }
  }

  void _onUpdateIsActive(
    RecurringPaymentFormUpdateIsActiveEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(isActive: event.isActive));
    }
  }

  void _onUpdateCategory(
    RecurringPaymentFormUpdateCategoryEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;
      emit(currentState.copyWith(category: event.category));
    }
  }

  void _onLoadExistingPayment(
    RecurringPaymentFormLoadExistingPaymentEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    try {
      emit(
        RecurringPaymentFormReadyState(
          name: event.payment.name,
          description: event.payment.description,
          provider: event.payment.provider,
          amount: event.payment.amount.toString(),
          selectedCard: event.payment.card,
          recurrenceType: event.payment.recurrenceType,
          paymentDateType: event.payment.paymentDateType,
          specificDay: event.payment.specificDay,
          secondSpecificDay: event.payment.secondSpecificDay,
          weekDay: event.payment.weekDay,
          weekDayOrdinal: event.payment.weekDayOrdinal,
          startDate: event.payment.startDate,
          endDate: event.payment.endDate,
          isActive: event.payment.isActive,
          category: event.payment.category,
        ),
      );
    } catch (e) {
      emit(
        RecurringPaymentFormErrorState(
          'Error al cargar el pago recurrente: $e',
        ),
      );
    }
  }

  void _onSave(
    RecurringPaymentFormSaveEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) async {
    if (state is RecurringPaymentFormReadyState) {
      final currentState = state as RecurringPaymentFormReadyState;

      try {
        // Validaciones
        if (currentState.name.isEmpty) {
          emit(
            RecurringPaymentFormErrorState('El nombre del pago es obligatorio'),
          );
          emit(currentState);
          return;
        }

        if (currentState.provider.isEmpty) {
          emit(
            RecurringPaymentFormErrorState(
              'El nombre del proveedor es obligatorio',
            ),
          );
          emit(currentState);
          return;
        }

        if (currentState.amount.isEmpty) {
          emit(RecurringPaymentFormErrorState('El monto es obligatorio'));
          emit(currentState);
          return;
        }

        double? amount = double.tryParse(
          currentState.amount.replaceAll(',', '.'),
        );
        if (amount == null || amount <= 0) {
          emit(
            RecurringPaymentFormErrorState(
              'El monto debe ser un número positivo',
            ),
          );
          emit(currentState);
          return;
        }

        // Validar día específico del mes
        if (currentState.paymentDateType == PaymentDateType.specificDay) {
          if (currentState.specificDay < 1 || currentState.specificDay > 31) {
            emit(
              RecurringPaymentFormErrorState('El día debe estar entre 1 y 31'),
            );
            emit(currentState);
            return;
          }
        }

        // Validar fecha de inicio y fin
        if (currentState.endDate != null &&
            currentState.endDate!.isBefore(currentState.startDate)) {
          emit(
            RecurringPaymentFormErrorState(
              'La fecha de fin debe ser posterior a la fecha de inicio',
            ),
          );
          emit(currentState);
          return;
        }

        // Nueva validación para pagos quincenales
        if (currentState.recurrenceType == RecurrenceType.biweekly &&
            currentState.paymentDateType == PaymentDateType.specificDay) {
          if (currentState.secondSpecificDay == null) {
            emit(
              RecurringPaymentFormErrorState(
                'Para pagos quincenales debe especificar el segundo día de pago',
              ),
            );
            emit(currentState);
            return;
          }

          // Verificar que los días sean diferentes
          if (currentState.specificDay == currentState.secondSpecificDay) {
            emit(
              RecurringPaymentFormErrorState(
                'Los dos días de pago quincenal deben ser diferentes',
              ),
            );
            emit(currentState);
            return;
          }
        }

        // Cambiar al estado de carga
        emit(RecurringPaymentFormLoadingState());

        // Generar ID o usar el existente
        final id =
            event.isEditing && event.paymentId != null
                ? event.paymentId!
                : DateTime.now().millisecondsSinceEpoch.toString();

        // Calcular la próxima fecha de pago
        final payment = RecurringPayment(
          id: id,
          name: currentState.name,
          description: currentState.description,
          provider: currentState.provider,
          amount: amount,
          card: currentState.selectedCard,
          recurrenceType: currentState.recurrenceType,
          paymentDateType: currentState.paymentDateType,
          specificDay: currentState.specificDay,
          secondSpecificDay:
              currentState.secondSpecificDay, // Incluir este campo
          weekDay: currentState.weekDay,
          weekDayOrdinal: currentState.weekDayOrdinal,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          isActive: currentState.isActive,
          category: currentState.category,
          nextPaymentDate: RecurringPaymentCalculator.calculateNextPaymentDate(
            // Aquí también incluir el segundo día específico
            RecurringPayment(
              id: id,
              name: currentState.name,
              provider: currentState.provider,
              amount: amount,
              recurrenceType: currentState.recurrenceType,
              paymentDateType: currentState.paymentDateType,
              specificDay: currentState.specificDay,
              secondSpecificDay: currentState.secondSpecificDay, // Incluir
              weekDay: currentState.weekDay,
              weekDayOrdinal: currentState.weekDayOrdinal,
              startDate: currentState.startDate,
              endDate: currentState.endDate,
            ),
          ),
        );

        if (event.isEditing) {
          // Actualizar pago existente
          recurringPaymentRepository.updateRecurringPaymentLocal(payment);
          emit(
            RecurringPaymentFormSuccessState(
              'Pago recurrente actualizado correctamente',
            ),
          );
        } else {
          // Crear nuevo pago
          recurringPaymentRepository.addRecurringPaymentLocal(payment);
          emit(
            RecurringPaymentFormSuccessState(
              'Pago recurrente guardado correctamente',
            ),
          );
        }

        // Intentar refrescar la lista si hay un contexto disponible
        if (event.context != null) {
          try {
            BlocProvider.of<RecurringPaymentBloc>(
              event.context!,
              listen: false,
            ).add(RefreshRecurringPaymentEvent());
          } catch (e) {
            debugPrint('No se pudo refrescar automáticamente: $e');
          }
        }
      } catch (e) {
        emit(
          RecurringPaymentFormErrorState(
            'Error al guardar el pago recurrente: $e',
          ),
        );
      }
    }
  }

  void _onDelete(
    RecurringPaymentFormDeleteEvent event,
    Emitter<RecurringPaymentFormState> emit,
  ) {
    try {
      // Buscar el pago por ID
      final payments = recurringPaymentRepository.getRecurringPaymentsLocal();
      final paymentToDelete = payments.firstWhere(
        (p) => p.id == event.paymentId,
      );

      // Eliminar el pago
      recurringPaymentRepository.deleteRecurringPaymentLocal(paymentToDelete);

      // Emitir estado de éxito
      emit(
        RecurringPaymentFormSuccessState(
          'Pago recurrente eliminado correctamente',
        ),
      );

      // Refrescar la lista de pagos
      BlocProvider.of<RecurringPaymentBloc>(
        event.context,
        listen: false,
      ).add(RefreshRecurringPaymentEvent());
    } catch (e) {
      emit(
        RecurringPaymentFormErrorState(
          'Error al eliminar el pago recurrente: $e',
        ),
      );
    }
  }
}
