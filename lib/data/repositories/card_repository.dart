import 'dart:convert';

import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/models/card.dart';

class CardRepository {
  final String _preferencesKey = 'cards';

  List<Card> getCardsLocal() {
    try {
      String json = Preferences.getString(_preferencesKey);
      if (json.isNotEmpty) {
        List<dynamic> jsonList = jsonDecode(json);
        return jsonList.map((e) => Card.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void saveCardsLocal(List<Card> cards) {
    String json = jsonEncode(cards);
    Preferences.setString(_preferencesKey, json);
  }

  void deleteAllCardsLocal() {
    Preferences.setString(_preferencesKey, '');
  }

  void addCardLocal(Card card) {
    List<Card> cards = getCardsLocal();
    cards.add(card);
    saveCardsLocal(cards);
  }

  void deleteCardLocal(Card card) {
    List<Card> cards = getCardsLocal();
    int index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards.removeAt(index);
      saveCardsLocal(cards);
    }
  }

  void updateCardLocal(Card card) {
    List<Card> cards = getCardsLocal();
    int index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      saveCardsLocal(cards);
    }
  }
}
