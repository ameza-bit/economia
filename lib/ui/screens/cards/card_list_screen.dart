// lib/ui/screens/cards/card_list_screen.dart
import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/ui/screens/cards/card_form_screen.dart';
import 'package:economia/ui/views/cards/card_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CardListScreen extends StatelessWidget {
  static const String routeName = 'card_list';
  const CardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Asegúrate de que el bloc recargue los datos cuando esta pantalla se carga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardBloc>().add(RefreshCardEvent());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tarjetas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CardBloc>().add(RefreshCardEvent()),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CardListView(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_new_card',
        tooltip: 'Agregar Tarjeta',
        child: const Icon(Icons.add),
        onPressed: () => context.goNamed(CardFormScreen.routeName),
      ),
    );
  }
}
