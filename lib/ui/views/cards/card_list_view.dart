// lib/ui/views/cards/card_list_view.dart
import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/ui/widgets/cards/card_item.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardListView extends StatelessWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CardBloc, CardState>(
      bloc: context.read<CardBloc>(),
      builder: (context, state) {
        switch (state) {
          case InitialCardState():
            return const Center(child: Text('Iniciando...'));

          case LoadingCardState():
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando tarjetas...'),
                ],
              ),
            );

          case ErrorCardState():
            return EmptyState(
              title: 'Error',
              subtitle: state.message,
              onRetry: () => context.read<CardBloc>().add(RefreshCardEvent()),
            );

          case LoadedCardState():
            if (state.cards.isEmpty) {
              return EmptyState(
                title: 'Sin Tarjetas',
                subtitle: 'No has registrado ninguna tarjeta todavía',
                onRetry: () => context.read<CardBloc>().add(RefreshCardEvent()),
              );
            }

            return ListView.builder(
              itemCount: state.cards.length,
              itemBuilder:
                  (context, index) => CardItem(card: state.cards[index]),
            );
        }
      },
    );
  }
}
