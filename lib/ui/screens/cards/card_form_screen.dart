// lib/ui/screens/cards/card_form_screen.dart
import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/ui/views/cards/card_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardFormScreen extends StatelessWidget {
  static const String routeName = 'card_form';
  const CardFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CardFormBloc(CardRepository())..add(CardFormInitEvent()),
      child: const CardFormView(),
    );
  }
}
