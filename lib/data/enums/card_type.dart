import 'package:flutter/material.dart';

enum CardType { credit, debit, gift, other }

extension CardTypeExtension on CardType {
  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case CardType.credit:
        return 'Crédito';
      case CardType.debit:
        return 'Débito';
      case CardType.gift:
        return 'Regalo';
      case CardType.other:
        return 'Otro';
    }
  }

  String get description {
    switch (this) {
      case CardType.credit:
        return 'Credit Card';
      case CardType.debit:
        return 'Debit Card';
      case CardType.gift:
        return 'Gift Card';
      case CardType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case CardType.credit:
        return 'assets/icons/credit_card.svg';
      case CardType.debit:
        return 'assets/icons/debit_card.svg';
      case CardType.gift:
        return 'assets/icons/gift_card.svg';
      case CardType.other:
        return 'assets/icons/other_card.svg';
    }
  }

  Color get color {
    switch (this) {
      case CardType.credit:
        return Colors.indigo.shade200;
      case CardType.debit:
        return Colors.teal.shade200;
      case CardType.gift:
        return Colors.amber.shade200;
      case CardType.other:
        return Colors.blueGrey.shade200;
    }
  }
}
