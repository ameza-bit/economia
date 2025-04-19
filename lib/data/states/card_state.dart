import 'package:economia/data/models/card.dart';

sealed class CardState {}

class InitialCardState extends CardState {}

class LoadingCardState extends CardState {}

class LoadedCardState extends CardState {
  final List<Card> cards;
  LoadedCardState(this.cards);
}

class ErrorCardState extends CardState {
  final String message;
  ErrorCardState(this.message);
}
