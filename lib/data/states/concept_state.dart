import 'package:economia/data/models/concept.dart';

sealed class ConceptState {}

class InitialConceptState extends ConceptState {}

class LoadingConceptState extends ConceptState {}

class LoadedConceptState extends ConceptState {
  final List<Concept> concepts;
  LoadedConceptState(this.concepts);
}

class ErrorConceptState extends ConceptState {
  final String message;
  ErrorConceptState(this.message);
}
