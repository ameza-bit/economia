import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/events/concept_form_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/concept_form_state.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptFormBloc extends Bloc<ConceptFormEvent, ConceptFormState> {
  final ConceptRepository conceptRepository;
  final CardRepository cardRepository;

  ConceptFormBloc({
    required this.conceptRepository,
    required this.cardRepository,
  }) : super(ConceptFormInitialState()) {
    on<ConceptFormInitEvent>(_onInit);
    on<ConceptFormUpdateNameEvent>(_onUpdateName);
    on<ConceptFormUpdateDescriptionEvent>(_onUpdateDescription);
    on<ConceptFormUpdateStoreEvent>(_onUpdateStore);
    on<ConceptFormUpdateTotalEvent>(_onUpdateTotal);
    on<ConceptFormUpdateSelectedCardEvent>(_onUpdateSelectedCard);
    on<ConceptFormUpdatePaymentModeEvent>(_onUpdatePaymentMode);
    on<ConceptFormUpdateMonthsEvent>(_onUpdateMonths);
    on<ConceptFormUpdatePurchaseDateEvent>(_onUpdatePurchaseDate);
    on<ConceptFormLoadExistingConceptEvent>(_onLoadExistingConcept);
    on<ConceptFormSaveEvent>(_onSave);
    on<ConceptFormDeleteEvent>(_onDelete);
  }

  void _onInit(ConceptFormInitEvent event, Emitter<ConceptFormState> emit) {
    try {
      // Obtener todas las tarjetas disponibles
      final cards = cardRepository.getCardsLocal();

      if (cards.isEmpty) {
        emit(ConceptFormReadyState(selectedCard: null));
      } else {
        emit(ConceptFormReadyState(selectedCard: cards.first));
      }
    } catch (e) {
      emit(ConceptFormErrorState('Error al inicializar: $e'));
    }
  }

  void _onUpdateName(
    ConceptFormUpdateNameEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(name: event.name));
    }
  }

  void _onUpdateDescription(
    ConceptFormUpdateDescriptionEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(description: event.description));
    }
  }

  void _onUpdateStore(
    ConceptFormUpdateStoreEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(store: event.store));
    }
  }

  void _onUpdateTotal(
    ConceptFormUpdateTotalEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(total: event.total));
    }
  }

  void _onUpdateSelectedCard(
    ConceptFormUpdateSelectedCardEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(selectedCard: event.card));
    }
  }

  void _onUpdatePaymentMode(
    ConceptFormUpdatePaymentModeEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;

      // Si se cambia a pago único, establecer meses en 1
      final updatedMonths =
          event.paymentMode == PaymentMode.oneTime ? 1 : currentState.months;

      emit(
        currentState.copyWith(
          paymentMode: event.paymentMode,
          months: updatedMonths,
        ),
      );
    }
  }

  void _onUpdateMonths(
    ConceptFormUpdateMonthsEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(months: event.months));
    }
  }

  void _onUpdatePurchaseDate(
    ConceptFormUpdatePurchaseDateEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;
      emit(currentState.copyWith(purchaseDate: event.purchaseDate));
    }
  }

  void _onLoadExistingConcept(
    ConceptFormLoadExistingConceptEvent event,
    Emitter<ConceptFormState> emit,
  ) {
    try {
      final concepts = conceptRepository.getConceptsLocal();
      final conceptToEdit = concepts.firstWhere((c) => c.id == event.conceptId);

      emit(
        ConceptFormReadyState(
          name: conceptToEdit.name,
          description: conceptToEdit.description,
          store: conceptToEdit.store,
          total: conceptToEdit.total.toString(),
          selectedCard: conceptToEdit.card,
          paymentMode: conceptToEdit.paymentMode,
          months: conceptToEdit.months,
          purchaseDate: conceptToEdit.purchaseDate,
        ),
      );
    } catch (e) {
      emit(ConceptFormErrorState('Error al cargar el concepto: $e'));
    }
  }

  void _onSave(
    ConceptFormSaveEvent event,
    Emitter<ConceptFormState> emit,
  ) async {
    if (state is ConceptFormReadyState) {
      final currentState = state as ConceptFormReadyState;

      try {
        // Validaciones
        if (currentState.name.isEmpty) {
          emit(ConceptFormErrorState('El nombre del concepto es obligatorio'));
          emit(currentState);
          return;
        }

        if (currentState.store.isEmpty) {
          emit(ConceptFormErrorState('El nombre de la tienda es obligatorio'));
          emit(currentState);
          return;
        }

        if (currentState.total.isEmpty) {
          emit(ConceptFormErrorState('El monto total es obligatorio'));
          emit(currentState);
          return;
        }

        double? totalAmount = double.tryParse(
          currentState.total.replaceAll(',', '.'),
        );
        if (totalAmount == null || totalAmount <= 0) {
          emit(
            ConceptFormErrorState('El monto total debe ser un número positivo'),
          );
          emit(currentState);
          return;
        }

        if (currentState.selectedCard == null) {
          emit(ConceptFormErrorState('Debe seleccionar una tarjeta'));
          emit(currentState);
          return;
        }

        if (currentState.paymentMode != PaymentMode.oneTime &&
            currentState.months < 1) {
          emit(ConceptFormErrorState('El número de meses debe ser al menos 1'));
          emit(currentState);
          return;
        }

        // Cambiar al estado de carga
        emit(ConceptFormLoadingState());

        // Generar ID o usar el existente
        final id =
            event.isEditing && event.conceptId != null
                ? event.conceptId!
                : DateTime.now().millisecondsSinceEpoch;

        final concept = Concept(
          id: id,
          name: currentState.name,
          description: currentState.description,
          store: currentState.store,
          total: totalAmount,
          card: currentState.selectedCard!,
          paymentMode: currentState.paymentMode,
          months: currentState.months,
          purchaseDate: currentState.purchaseDate,
        );

        if (event.isEditing) {
          // Actualizar concepto existente
          conceptRepository.updateConceptLocal(concept);
          emit(ConceptFormSuccessState('Concepto actualizado correctamente'));
        } else {
          // Crear nuevo concepto
          conceptRepository.addConceptLocal(concept);
          emit(ConceptFormSuccessState('Concepto guardado correctamente'));
        }

        // Intentar refrescar la lista de conceptos si hay un contexto disponible
        if (event.context != null) {
          try {
            // Verificar si existe un ConceptBloc antes de usarlo
            BlocProvider.of<ConceptBloc>(
              event.context!,
              listen: false,
            ).add(RefreshConceptEvent());
          } catch (e) {
            // Si no se puede acceder al ConceptBloc, simplemente continuamos
            // El usuario verá el mensaje de éxito igualmente
            debugPrint('No se pudo refrescar automáticamente: $e');
          }
        }
      } catch (e) {
        emit(ConceptFormErrorState('Error al guardar el concepto: $e'));
      }
    }
  }

  void _onDelete(ConceptFormDeleteEvent event, Emitter<ConceptFormState> emit) {
    try {
      // Buscar el concepto por ID
      final concepts = conceptRepository.getConceptsLocal();
      final conceptToDelete = concepts.firstWhere(
        (c) => c.id == event.conceptId,
      );

      // Eliminar el concepto
      conceptRepository.deleteConceptLocal(conceptToDelete);

      // Emitir estado de éxito
      emit(ConceptFormSuccessState('Concepto eliminado correctamente'));

      // Refrescar la lista de conceptos
      BlocProvider.of<ConceptBloc>(
        event.context,
        listen: false,
      ).add(RefreshConceptEvent());
    } catch (e) {
      emit(ConceptFormErrorState('Error al eliminar el concepto: $e'));
    }
  }
}
