import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/data/states/concept_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptBloc extends Bloc<ConceptEvent, ConceptState> {
  final ConceptRepository repository;
  List<Concept> _concepts = [];

  ConceptBloc({required this.repository}) : super(InitialConceptState()) {
    on<LoadConceptEvent>(_onLoadConcepts);
    on<RefreshConceptEvent>(_onRefreshConcepts);
    on<ToggleConceptPaidStatusEvent>(_onTogglePaidStatus);
  }

  void _onLoadConcepts(
    LoadConceptEvent event,
    Emitter<ConceptState> emit,
  ) async {
    try {
      emit(LoadingConceptState());
      _concepts = repository.getConceptsLocal();
      emit(LoadedConceptState(_concepts));
    } catch (e) {
      emit(ErrorConceptState("Error loading concepts: $e"));
    }
  }

  void _onRefreshConcepts(
    RefreshConceptEvent event,
    Emitter<ConceptState> emit,
  ) async {
    try {
      emit(LoadingConceptState());
      _concepts = repository.getConceptsLocal();
      emit(LoadedConceptState(_concepts));
    } catch (e) {
      emit(ErrorConceptState("Error loading concepts: $e"));
    }
  }

  void _onTogglePaidStatus(
    ToggleConceptPaidStatusEvent event,
    Emitter<ConceptState> emit,
  ) async {
    try {
      emit(LoadingConceptState());

      // Crear una copia del concepto con el estado cambiado
      final updatedConcept = event.concept.copyWith(
        manuallyMarkedAsPaid: event.isPaid,
      );

      // Actualizar en el repositorio
      repository.updateConceptLocal(updatedConcept);

      // Recargar la lista completa
      _concepts = repository.getConceptsLocal();
      emit(LoadedConceptState(_concepts));
    } catch (e) {
      emit(ErrorConceptState("Error al actualizar el estado de pago: $e"));
    }
  }
}
