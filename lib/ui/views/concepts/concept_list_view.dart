import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/states/concept_state.dart';
import 'package:economia/ui/widgets/concepts/concept_card.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptListView extends StatelessWidget {
  const ConceptListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConceptBloc, ConceptState>(
      builder: (BuildContext context, ConceptState state) {
        switch (state) {
          case InitialConceptState():
            return Center(child: Text('Iniciando...'));
          case LoadingConceptState():
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando Conceptos...'),
                ],
              ),
            );
          case ErrorConceptState():
            return EmptyState(
              subtitle: state.message,
              onRetry:
                  () => context.read<ConceptBloc>().add(RefreshConceptEvent()),
            );
          case LoadedConceptState():
            if (state.concepts.isEmpty) {
              // return Center(child: Text('No hay conceptos disponibles'));
              return EmptyState(
                subtitle: 'No hay conceptos disponibles',
                onRetry:
                    () =>
                        context.read<ConceptBloc>().add(RefreshConceptEvent()),
              );
            }

            return ListView.builder(
              itemCount: state.concepts.length,
              itemBuilder:
                  (context, index) =>
                      ConceptCard(concept: state.concepts[index]),
            );
        }
      },
    );
  }
}
