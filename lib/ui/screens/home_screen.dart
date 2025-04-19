import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/ui/views/concept_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocProvider(
          create: (_) => ConceptBloc()..add(LoadConceptEvent()),
          child: ConceptListView(),
        ),
      ),
    );
  }
}
