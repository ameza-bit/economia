import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardType', () {
    test('name devuelve el nombre correcto para cada tipo', () {
      expect(CardType.credit.name, equals('credit'));
      expect(CardType.debit.name, equals('debit'));
      expect(CardType.gift.name, equals('gift'));
      expect(CardType.other.name, equals('other'));
    });

    test('displayName devuelve el nombre localizado para cada tipo', () {
      expect(CardType.credit.displayName, equals('Crédito'));
      expect(CardType.debit.displayName, equals('Débito'));
      expect(CardType.gift.displayName, equals('Regalo'));
      expect(CardType.other.displayName, equals('Otro'));
    });

    test('description devuelve la descripción en inglés para cada tipo', () {
      expect(CardType.credit.description, equals('Credit Card'));
      expect(CardType.debit.description, equals('Debit Card'));
      expect(CardType.gift.description, equals('Gift Card'));
      expect(CardType.other.description, equals('Other'));
    });

    test('icon devuelve la ruta al SVG correspondiente para cada tipo', () {
      expect(CardType.credit.icon, equals('assets/icons/credit_card.svg'));
      expect(CardType.debit.icon, equals('assets/icons/debit_card.svg'));
      expect(CardType.gift.icon, equals('assets/icons/gift_card.svg'));
      expect(CardType.other.icon, equals('assets/icons/other_card.svg'));
    });

    test('color devuelve un color Material para cada tipo', () {
      expect(CardType.credit.color, equals(Colors.indigo.shade200));
      expect(CardType.debit.color, equals(Colors.teal.shade200));
      expect(CardType.gift.color, equals(Colors.amber.shade200));
      expect(CardType.other.color, equals(Colors.blueGrey.shade200));
    });
  });

  group('CardNetwork', () {
    test('name devuelve el nombre correcto para cada red', () {
      expect(CardNetwork.visa.name, equals('visa'));
      expect(CardNetwork.mastercard.name, equals('mastercard'));
      expect(CardNetwork.americanExpress.name, equals('americanExpress'));
      expect(CardNetwork.other.name, equals('other'));
    });

    test('displayName devuelve el nombre localizado para cada red', () {
      expect(CardNetwork.visa.displayName, equals('Visa'));
      expect(CardNetwork.mastercard.displayName, equals('MasterCard'));
      expect(
        CardNetwork.americanExpress.displayName,
        equals('American Express'),
      );
      expect(CardNetwork.other.displayName, equals('Otra'));
    });

    test('color devuelve un color Material para cada red', () {
      expect(CardNetwork.visa.color, equals(Colors.blue.shade700));
      expect(CardNetwork.mastercard.color, equals(Colors.red.shade700));
      expect(CardNetwork.americanExpress.color, equals(Colors.indigo.shade700));
      expect(CardNetwork.other.color, equals(Colors.grey.shade700));
    });

    test('icon devuelve un IconData para cada red', () {
      expect(CardNetwork.visa.icon, equals(Icons.credit_card));
      expect(CardNetwork.mastercard.icon, equals(Icons.credit_card));
      expect(CardNetwork.americanExpress.icon, equals(Icons.credit_card));
      expect(CardNetwork.other.icon, equals(Icons.credit_card));
    });
  });
}
