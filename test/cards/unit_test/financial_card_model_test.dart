import 'dart:convert';

import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FinancialCard', () {
    test('fromJson crea una tarjeta correctamente', () {
      // Arrange
      final Map<String, dynamic> json = {
        'id': 'test-id-123',
        'cardNumber': 1234567890123456,
        'cardType': CardType.credit.index,
        'expirationDate': '2025-12-01T00:00:00.000',
        'paymentDay': 15,
        'cutOffDay': 8,
        'bankName': 'Banco Test',
        'alias': 'Tarjeta Test',
        'cardholderName': 'Usuario Test',
        'cardNetwork': CardNetwork.visa.index,
      };

      // Act
      final FinancialCard card = FinancialCard.fromJson(json);

      // Assert
      expect(card.id, equals('test-id-123'));
      expect(card.cardNumber, equals(1234567890123456));
      expect(card.cardType, equals(CardType.credit));
      expect(card.expirationDate, equals(DateTime(2025, 12, 1)));
      expect(card.paymentDay, equals(15));
      expect(card.cutOffDay, equals(8));
      expect(card.bankName, equals('Banco Test'));
      expect(card.alias, equals('Tarjeta Test'));
      expect(card.cardholderName, equals('Usuario Test'));
      expect(card.cardNetwork, equals(CardNetwork.visa));
    });

    test('toJson convierte una tarjeta a JSON correctamente', () {
      // Arrange
      final FinancialCard card = FinancialCard(
        id: 'test-id-123',
        cardNumber: 1234567890123456,
        cardType: CardType.credit,
        expirationDate: DateTime(2025, 12, 1),
        paymentDay: 15,
        cutOffDay: 8,
        bankName: 'Banco Test',
        alias: 'Tarjeta Test',
        cardholderName: 'Usuario Test',
        cardNetwork: CardNetwork.visa,
      );

      // Act
      final Map<String, dynamic> json = card.toJson();

      // Assert
      expect(json['id'], equals('test-id-123'));
      expect(json['cardNumber'], equals(1234567890123456));
      expect(json['cardType'], equals(CardType.credit.index));
      expect(json['expirationDate'], equals('2025-12-01T00:00:00.000'));
      expect(json['paymentDay'], equals(15));
      expect(json['cutOffDay'], equals(8));
      expect(json['bankName'], equals('Banco Test'));
      expect(json['alias'], equals('Tarjeta Test'));
      expect(json['cardholderName'], equals('Usuario Test'));
      expect(json['cardNetwork'], equals(CardNetwork.visa.index));
    });

    test('fromJson maneja valores faltantes con valores predeterminados', () {
      // Arrange - JSON con valores mínimos
      final Map<String, dynamic> json = {
        'id': 'test-id-456',
        'cardNumber': 4321,
      };

      // Act
      final FinancialCard card = FinancialCard.fromJson(json);

      // Assert
      expect(card.id, equals('test-id-456'));
      expect(card.cardNumber, equals(4321));
      expect(card.cardType, equals(CardType.other)); // Valor por defecto
      expect(card.paymentDay, equals(1)); // Valor por defecto
      expect(card.cutOffDay, equals(15)); // Valor por defecto
      expect(card.bankName, equals('')); // Valor por defecto
      expect(card.alias, equals('')); // Valor por defecto
      expect(card.cardholderName, equals('')); // Valor por defecto
      expect(card.cardNetwork, equals(CardNetwork.other)); // Valor por defecto
      // La fecha de expiración será DateTime.now() si falta
    });

    test('fromJson y toJson son inversos', () {
      // Arrange
      final FinancialCard originalCard = FinancialCard(
        id: 'test-id-789',
        cardNumber: 9876543210123456,
        cardType: CardType.debit,
        expirationDate: DateTime(2026, 6, 15),
        paymentDay: 20,
        cutOffDay: 10,
        bankName: 'Otro Banco',
        alias: 'Tarjeta Personal',
        cardholderName: 'Ana García',
        cardNetwork: CardNetwork.mastercard,
      );

      // Act
      final Map<String, dynamic> json = originalCard.toJson();
      final FinancialCard reconstructedCard = FinancialCard.fromJson(json);

      // Assert
      expect(reconstructedCard.id, equals(originalCard.id));
      expect(reconstructedCard.cardNumber, equals(originalCard.cardNumber));
      expect(reconstructedCard.cardType, equals(originalCard.cardType));
      expect(
        reconstructedCard.expirationDate,
        equals(originalCard.expirationDate),
      );
      expect(reconstructedCard.paymentDay, equals(originalCard.paymentDay));
      expect(reconstructedCard.cutOffDay, equals(originalCard.cutOffDay));
      expect(reconstructedCard.bankName, equals(originalCard.bankName));
      expect(reconstructedCard.alias, equals(originalCard.alias));
      expect(
        reconstructedCard.cardholderName,
        equals(originalCard.cardholderName),
      );
      expect(reconstructedCard.cardNetwork, equals(originalCard.cardNetwork));
    });

    test(
      'el modelo se puede serializar y deserializar usando jsonEncode/jsonDecode',
      () {
        // Arrange
        final FinancialCard originalCard = FinancialCard(
          id: 'test-id-910',
          cardNumber: 1122334455667788,
          cardType: CardType.gift,
          expirationDate: DateTime(2027, 3, 10),
          paymentDay: 5,
          cutOffDay: 25,
          bankName: 'Banco Regalo',
          alias: 'Tarjeta Regalo',
          cardholderName: 'Carlos Rodríguez',
          cardNetwork: CardNetwork.other,
        );

        // Act
        final String jsonString = jsonEncode(originalCard.toJson());
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        final FinancialCard reconstructedCard = FinancialCard.fromJson(jsonMap);

        // Assert
        expect(reconstructedCard.id, equals(originalCard.id));
        expect(reconstructedCard.cardNumber, equals(originalCard.cardNumber));
        expect(reconstructedCard.cardType, equals(originalCard.cardType));
        expect(
          reconstructedCard.expirationDate,
          equals(originalCard.expirationDate),
        );
        expect(reconstructedCard.paymentDay, equals(originalCard.paymentDay));
        expect(reconstructedCard.cutOffDay, equals(originalCard.cutOffDay));
        expect(reconstructedCard.bankName, equals(originalCard.bankName));
        expect(reconstructedCard.alias, equals(originalCard.alias));
        expect(
          reconstructedCard.cardholderName,
          equals(originalCard.cardholderName),
        );
        expect(reconstructedCard.cardNetwork, equals(originalCard.cardNetwork));
      },
    );
  });
}
