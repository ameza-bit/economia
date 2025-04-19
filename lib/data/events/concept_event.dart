sealed class ConceptEvent {}

class InitialConceptEvent extends ConceptEvent {}

class LoadConceptEvent extends ConceptEvent {}

class RefreshConceptEvent extends ConceptEvent {}