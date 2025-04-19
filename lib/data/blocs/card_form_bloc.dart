import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/events/card_event.dart';
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
    on<CardFormUpdateAliasEvent>(_onUpdateAlias);
    on<CardFormUpdateCardholderNameEvent>(_onUpdateCardholderName);
    on<CardFormUpdateCardNetworkEvent>(_onUpdateCardNetwork);
    on<CardFormSaveEvent>(_onSave);
    on<CardFormLoadExistingCardEvent>(_onLoadExistingCard);
    on<CardFormDeleteEvent>(_onDelete);
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

  // Métodos existentes...
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

  // Nuevos métodos para los nuevos eventos
  void _onUpdateAlias(
    CardFormUpdateAliasEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(alias: event.alias));
    }
  }

  void _onUpdateCardholderName(
    CardFormUpdateCardholderNameEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(cardholderName: event.cardholderName));
    }
  }

  void _onUpdateCardNetwork(
    CardFormUpdateCardNetworkEvent event,
    Emitter<CardFormState> emit,
  ) {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;
      emit(currentState.copyWith(cardNetwork: event.cardNetwork));
    }
  }

  void _onSave(CardFormSaveEvent event, Emitter<CardFormState> emit) async {
    if (state is CardFormReadyState) {
      final currentState = state as CardFormReadyState;

      try {
        if (currentState.cardNumber.isEmpty) {
          emit(CardFormErrorState('Ingrese el número de tarjeta'));
          emit(currentState);
          return;
        }

        if (currentState.bankName.isEmpty) {
          emit(CardFormErrorState('Ingrese el nombre del banco'));
          emit(currentState); // Volver al estado anterior
          return;
        }

        if (currentState.cardholderName.isEmpty) {
          emit(CardFormErrorState('Ingrese el nombre del titular'));
          emit(currentState); // Volver al estado anterior
          return;
        }

        // Validar que los días están en un rango válido si es tarjeta de crédito
        if (currentState.cardType == CardType.credit ||
            currentState.cardType == CardType.other) {
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
        }

        // Ahora emitimos el estado de carga
        emit(CardFormLoadingState());

        // Generar ID o usar el existente según sea edición o creación
        final id =
            event.isEditing && event.cardId != null
                ? event.cardId!
                : DateTime.now().millisecondsSinceEpoch.toString();

        final card = FinancialCard(
          id: id,
          cardNumber: int.parse(currentState.cardNumber),
          cardType: currentState.cardType,
          expirationDate: currentState.expirationDate,
          paymentDay: currentState.paymentDay,
          cutOffDay: currentState.cutOffDay,
          bankName: currentState.bankName,
          alias: currentState.alias,
          cardholderName: currentState.cardholderName,
          cardNetwork: currentState.cardNetwork,
        );

        if (event.isEditing) {
          // Actualizar tarjeta existente
          repository.updateCardLocal(card);
          emit(CardFormSuccessState('Tarjeta actualizada correctamente'));
        } else {
          // Crear nueva tarjeta
          repository.addCardLocal(card);
          emit(CardFormSuccessState('Tarjeta guardada correctamente'));
        }

        if (event.context != null) {
          BlocProvider.of<CardBloc>(
            event.context!,
            listen: false,
          ).add(RefreshCardEvent());
        }
      } catch (e) {
        emit(CardFormErrorState('Error al guardar la tarjeta: $e'));
      }
    }
  }

  void _onLoadExistingCard(
    CardFormLoadExistingCardEvent event,
    Emitter<CardFormState> emit,
  ) {
    emit(
      CardFormReadyState(
        cardNumber: event.card.cardNumber.toString(),
        bankName: event.card.bankName,
        cardType: event.card.cardType,
        expirationDate: event.card.expirationDate,
        paymentDay: event.card.paymentDay,
        cutOffDay: event.card.cutOffDay,
        alias: event.card.alias,
        cardholderName: event.card.cardholderName,
        cardNetwork: event.card.cardNetwork,
      ),
    );
  }

  void _onDelete(CardFormDeleteEvent event, Emitter<CardFormState> emit) {
    try {
      // Buscar la tarjeta por ID
      final cards = repository.getCardsLocal();
      final cardToDelete = cards.firstWhere((card) => card.id == event.cardId);

      // Eliminar la tarjeta
      repository.deleteCardLocal(cardToDelete);

      // Emitir estado de éxito
      emit(CardFormSuccessState('Tarjeta eliminada correctamente'));

      // Refrescar la lista de tarjetas
      BlocProvider.of<CardBloc>(
        event.context,
        listen: false,
      ).add(RefreshCardEvent());
    } catch (e) {
      emit(CardFormErrorState('Error al eliminar la tarjeta: $e'));
    }
  }
}
