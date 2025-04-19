import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/ui/screens/cards/card_list_screen.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/views/concepts/concept_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConceptListScreen extends StatelessWidget {
  static const String routeName = 'concept_list';
  const ConceptListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegurarnos de que el bloc recargue los datos cuando esta pantalla se carga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ConceptBloc>().add(RefreshConceptEvent());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Economía'),
        centerTitle: true,
        actions: [
          // Botón para ir a la lista de tarjetas
          IconButton(
            icon: const Icon(Icons.credit_card),
            tooltip: 'Ver Tarjetas',
            onPressed: () => context.goNamed(CardListScreen.routeName),
          ),
          // Botón de actualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed:
                () => context.read<ConceptBloc>().add(RefreshConceptEvent()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ConceptListView(),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_concept'),
        heroTag: 'add_concept',
        child: const Icon(Icons.add_outlined),
        onPressed: () => context.goNamed(ConceptFormScreen.routeName),
      ),
    );
  }
}
