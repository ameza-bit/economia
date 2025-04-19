import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/ui/views/cards/card_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardFormScreen extends StatelessWidget {
  static const String routeName = 'card_form';

  const CardFormScreen({super.key, this.isEditing = false, this.card});

  final bool isEditing;
  final FinancialCard? card;

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) {
        final bloc = CardFormBloc(CardRepository());
        // Si estamos en modo edición, cargar la tarjeta existente
        if (isEditing && card != null) {
          bloc.add(CardFormLoadExistingCardEvent(card!));
        } else {
          bloc.add(CardFormInitEvent());
        }
        return bloc;
      },
      child: CardFormView(isEditing: isEditing, cardId: card?.id),
    );
  }
}
