import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  CardRepository repository;
  List<FinancialCard> _cards = [];

  CardBloc({required this.repository}) : super(InitialCardState()) {
    on<LoadCardEvent>(_onLoadCards);
    on<RefreshCardEvent>(_onRefreshCards);
  }

  void _onLoadCards(LoadCardEvent event, Emitter<CardState> emit) async {
    try {
      emit(LoadingCardState());
      _cards = repository.getCardsLocal();
      emit(LoadedCardState(_cards));
    } catch (e) {
      emit(ErrorCardState("Error loading cards: $e"));
    }
  }

  void _onRefreshCards(RefreshCardEvent event, Emitter<CardState> emit) async {
    try {
      emit(LoadingCardState());
      _cards = repository.getCardsLocal();
      emit(LoadedCardState(_cards));
    } catch (e) {
      emit(ErrorCardState("Error loading cards: $e"));
    }
  }
}
