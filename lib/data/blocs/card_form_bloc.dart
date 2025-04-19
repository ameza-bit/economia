// lib/data/blocs/card_form_bloc.dart
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardFormBloc extends Bloc<CardFormEvent, CardFormState> {
  final CardRepository repository;

  CardFormBloc(this.repository) : super(CardFormInitialState()) {
    on<CardFormInitEvent>(_onInit);
    on<CardFormUpdateCardNumberEvent>(_onUpdateCardNumber);
    on<CardFormUpdateBankNameEvent>(_onUpdateBankName);
    on<CardFormUpdateCardTypeEvent>(_onUpdateCardType);
    on<CardFormUpdateExpirationDateEvent>(_onUpdateExpirationDate);
    on<CardFormUpdatePaymentDayEvent>(_onUpdatePaymentDay);
    on<CardFormUpdateCutOffDayEvent>(_onUpdateCutOffDay);
    on<CardFormSaveEvent>(_onSave);
  }

  void _onInit(CardFormInitEvent event, Emitter<CardFormState> emit) {
    final now = DateTime.now();
    emit(
      CardFormReadyState(
        expirationDate: DateTime(now.year + 2, now.month, 1),
        paymentDay: now.day,
        cutOffDay: now.day > 7 ? now.day - 7 : now.day + 23,
      ),
    );
  }

  void _onUpdateCardNumber(
    CardFormUpdateCardNumberEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(cardNumber: event.cardNumber));
    }
  }

  void _onUpdateBankName(
    CardFormUpdateBankNameEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(bankName: event.bankName));
    }
  }

  void _onUpdateCardType(
    CardFormUpdateCardTypeEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(cardType: event.cardType));
    }
  }

  void _onUpdateExpirationDate(
    CardFormUpdateExpirationDateEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(
        currentState.copyWith(
          expirationDate: DateTime(event.year, event.month, 1),
        ),
      );
    }
  }

  void _onUpdatePaymentDay(
    CardFormUpdatePaymentDayEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(paymentDay: event.day));
    }
  }

  void _onUpdateCutOffDay(
    CardFormUpdateCutOffDayEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(cutOffDay: event.day));
    }
  }

  void _onSave(CardFormSaveEvent event, Emitter<CardFormState> emit) async {
    if (state is CardFormReadyState) {
      try {
        emit(CardFormLoadingState());

        final currentState = state as CardFormReadyState;

        // Validaciones básicas
        if (currentState.cardNumber.isEmpty) {
          emit(CardFormErrorState('Ingrese el número de tarjeta'));
          emit(currentState);
          return;
        }

        if (currentState.bankName.isEmpty) {
          emit(CardFormErrorState('Ingrese el nombre del banco'));
          emit(currentState);
          return;
        }

        // Validar que los días están en un rango válido
        if (currentState.paymentDay < 1 || currentState.paymentDay > 31) {
          emit(CardFormErrorState('El día de pago debe estar entre 1 y 31'));
          emit(currentState);
          return;
        }

        if (currentState.cutOffDay < 1 || currentState.cutOffDay > 31) {
          emit(CardFormErrorState('El día de corte debe estar entre 1 y 31'));
          emit(currentState);
          return;
        }

        // Generar un ID simple usando timestamp
        final id = DateTime.now().millisecondsSinceEpoch.toString();

        // Crear objeto de tarjeta
        final newCard = FinancialCard(
          id: id,
          cardNumber: int.parse(currentState.cardNumber),
          cardType: currentState.cardType,
          expirationDate: currentState.expirationDate,
          paymentDay:
              currentState.paymentDay, // Ahora es simplemente el día como int
          cutOffDay:
              currentState.cutOffDay, // Ahora es simplemente el día como int
          bankName: currentState.bankName,
        );

        // Guardar tarjeta
        repository.addCardLocal(newCard);

        emit(CardFormSuccessState('Tarjeta guardada correctamente'));
      } catch (e) {
        emit(CardFormErrorState('Error al guardar la tarjeta: $e'));
      }
    }
  }
}
