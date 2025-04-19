import 'dart:convert';

import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/src/shared_preferences_legacy.dart';

// Crear una clase mock para Preferences usando Mocktail
class MockPreferences extends Mock implements Preferences {
  String getString(String key) => ""; // Proporcionar implementación por defecto
}

// Crear una implementación testeable de CardRepository
class TestableCardRepository extends CardRepository {}

void main() {
  late CardRepository repository;
  late MockPreferences mockPreferences;

  // Preparar datos de prueba
  final testCard1 = FinancialCard(
    id: '1',
    cardNumber: 1234,
    cardType: CardType.credit,
    expirationDate: DateTime(2025, 12, 1),
    paymentDay: 15,
    cutOffDay: 8,
    bankName: 'Banco Test',
    alias: 'Tarjeta Test',
    cardholderName: 'Usuario Test',
    cardNetwork: CardNetwork.visa,
  );

  final testCard2 = FinancialCard(
    id: '2',
    cardNumber: 5678,
    cardType: CardType.debit,
    expirationDate: DateTime(2026, 6, 1),
    paymentDay: 1,
    cutOffDay: 25,
    bankName: 'Otro Banco',
    alias: 'Débito Personal',
    cardholderName: 'Usuario Test',
    cardNetwork: CardNetwork.mastercard,
  );

  final testCards = [testCard1, testCard2];
  final testCardsJson = jsonEncode(testCards.map((e) => e.toJson()).toList());

  setUp(() {
    mockPreferences = MockPreferences();
    repository = TestableCardRepository();

    // Reemplazar la implementación de Preferences con nuestro mock
    Preferences.pref = mockPreferences as SharedPreferences;
  });

  group('CardRepository', () {
    test(
      'getCardsLocal debe retornar una lista vacía cuando no hay tarjetas guardadas',
      () {
        // Arrange
        when(() => mockPreferences.getString(any())).thenReturn('');

        // Act
        final result = repository.getCardsLocal();

        // Assert
        expect(result, isEmpty);
        verify(() => mockPreferences.getString('cards')).called(1);
      },
    );

    test(
      'getCardsLocal debe retornar la lista de tarjetas cuando hay tarjetas guardadas',
      () {
        // Arrange
        when(() => mockPreferences.getString(any())).thenReturn(testCardsJson);

        // Act
        final result = repository.getCardsLocal();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].id, equals('1'));
        expect(result[1].id, equals('2'));
        verify(() => mockPreferences.getString('cards')).called(1);
      },
    );

    test('getCardsLocal debe manejar errores y retornar una lista vacía', () {
      // Arrange
      when(
        () => mockPreferences.getString(any()),
      ).thenThrow(Exception('Error de prueba'));

      // Act
      final result = repository.getCardsLocal();

      // Assert
      expect(result, isEmpty);
      verify(() => mockPreferences.getString('cards')).called(1);
    });

    test('addCardLocal debe agregar una tarjeta a la lista existente', () {
      // Arrange
      final newCard = FinancialCard(
        id: '3',
        cardNumber: 9876,
        cardType: CardType.gift,
        expirationDate: DateTime(2027, 1, 1),
        paymentDay: 10,
        cutOffDay: 3,
        bankName: 'Banco Nuevo',
        alias: 'Tarjeta Regalo',
        cardholderName: 'Nuevo Usuario',
        cardNetwork: CardNetwork.other,
      );

      when(() => mockPreferences.getString(any())).thenReturn(testCardsJson);

      // Act
      repository.addCardLocal(newCard);

      // Assert
      // Verificar que se obtuvieron las tarjetas existentes
      verify(() => mockPreferences.getString('cards')).called(1);

      // Verificar que se guardó la lista con la nueva tarjeta
      final List<dynamic> expectedCards = [...testCards, newCard];
      final expectedCardsJson = jsonEncode(
        expectedCards.map((e) => e.toJson()).toList(),
      );
      verify(() => Preferences.setString('cards', expectedCardsJson)).called(1);

      // Verificar que setString fue llamado con la lista actualizada
      verify(() => Preferences.setString('cards', any())).called(1);
    });

    test('updateCardLocal debe actualizar una tarjeta existente', () {
      // Arrange
      final updatedCard = FinancialCard(
        id: '1', // Mismo ID que testCard1
        cardNumber: 1234,
        cardType: CardType.credit,
        expirationDate: DateTime(2025, 12, 1),
        paymentDay: 20, // Cambiado de 15 a 20
        cutOffDay: 10, // Cambiado de 8 a 10
        bankName: 'Banco Actualizado', // Nombre cambiado
        alias: 'Tarjeta Test',
        cardholderName: 'Usuario Test',
        cardNetwork: CardNetwork.visa,
      );

      when(() => mockPreferences.getString(any())).thenReturn(testCardsJson);

      // Act
      repository.updateCardLocal(updatedCard);

      // Assert
      verify(() => mockPreferences.getString('cards')).called(1);
      verify(() => Preferences.setString('cards', any())).called(1);
    });

    test('deleteCardLocal debe eliminar una tarjeta existente', () {
      // Arrange
      when(() => mockPreferences.getString(any())).thenReturn(testCardsJson);

      // Act
      repository.deleteCardLocal(testCard1);

      // Assert
      verify(() => mockPreferences.getString('cards')).called(1);
      verify(() => Preferences.setString('cards', any())).called(1);
    });

    test('deleteAllCardsLocal debe eliminar todas las tarjetas', () {
      // Act
      repository.deleteAllCardsLocal();

      // Assert
      verify(() => Preferences.setString('cards', '')).called(1);
    });
  });
}
