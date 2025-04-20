import 'package:economia/data/blocs/concept_form_bloc.dart';
import 'package:economia/data/events/concept_form_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/ui/views/concepts/concept_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptFormScreen extends StatelessWidget {
  static const String routeName = 'concept_form';

  const ConceptFormScreen({super.key, this.isEditing = false, this.concept});

  final bool isEditing;
  final Concept? concept;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ConceptFormBloc(
          conceptRepository: ConceptRepository(),
          cardRepository: CardRepository(),
        );

        // Si estamos en modo edición, cargar el concepto existente
        if (isEditing && concept != null) {
          bloc.add(ConceptFormLoadExistingConceptEvent(concept!.id));
        } else {
          bloc.add(ConceptFormInitEvent());
        }

        return bloc;
      },
      child: ConceptFormView(isEditing: isEditing, conceptId: concept?.id),
    );
  }
}
