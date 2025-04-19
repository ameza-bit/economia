import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/ui/views/concepts/concept_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptListScreen extends StatelessWidget {
  static const String routeName = 'concept_list';
  const ConceptListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocProvider(
          create:
              (_) =>
                  ConceptBloc(repository: ConceptRepository())
                    ..add(LoadConceptEvent()),
          child: ConceptListView(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_outlined),
        onPressed: () {},
      ),
    );
  }
}
