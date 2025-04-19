// lib/data/enums/card_network.dart
import 'package:flutter/material.dart';

enum CardNetwork { visa, mastercard, americanExpress, other }

extension CardNetworkExtension on CardNetwork {
  String get name => toString().split('.').last;

  String get displayName {
    switch (this) {
      case CardNetwork.visa:
        return 'Visa';
      case CardNetwork.mastercard:
        return 'MasterCard';
      case CardNetwork.americanExpress:
        return 'American Express';
      case CardNetwork.other:
        return 'Otra';
    }
  }

  Color get color {
    switch (this) {
      case CardNetwork.visa:
        return Colors.blue.shade700;
      case CardNetwork.mastercard:
        return Colors.red.shade700;
      case CardNetwork.americanExpress:
        return Colors.indigo.shade700;
      case CardNetwork.other:
        return Colors.grey.shade700;
    }
  }

  IconData get icon {
    switch (this) {
      case CardNetwork.visa:
        return Icons.credit_card;
      case CardNetwork.mastercard:
        return Icons.credit_card;
      case CardNetwork.americanExpress:
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
