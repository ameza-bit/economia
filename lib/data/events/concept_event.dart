import 'package:economia/data/models/concept.dart';

sealed class ConceptEvent {}

class LoadConceptEvent extends ConceptEvent {}

class RefreshConceptEvent extends ConceptEvent {}

class ToggleConceptPaidStatusEvent extends ConceptEvent {
  final Concept concept;
  final bool isPaid;

  ToggleConceptPaidStatusEvent({required this.concept, required this.isPaid});
}
