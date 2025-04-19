import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/data/states/concept_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptBloc extends Bloc<ConceptEvent, ConceptState> {
  final ConceptRepository conceptRepository = ConceptRepository();
  List<Concept> _concepts = [];

  ConceptBloc() : super(InitialConceptState()) {
    on<LoadConceptEvent>(_onLoadConcepts);
    on<RefreshConceptEvent>(_onRefreshConcepts);
  }

  void _onLoadConcepts(
    LoadConceptEvent event,
    Emitter<ConceptState> emit,
  ) async {
    try {
      emit(LoadingConceptState());
      _concepts = conceptRepository.getConceptsLocal();
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
      _concepts = conceptRepository.getConceptsLocal();
      emit(LoadedConceptState(_concepts));
    } catch (e) {
      emit(ErrorConceptState("Error loading concepts: $e"));
    }
  }
}
