import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/ui/widgets/cards/card_item.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest(FinancialCard card) {
    return MaterialApp(home: Scaffold(body: CardItem(card: card)));
  }

  group('CardItem', () {
    testWidgets(
      'muestra correctamente la información de una tarjeta de crédito',
      (WidgetTester tester) async {
        // Arrange
        final testCard = FinancialCard(
          id: '1',
          cardNumber: 1234567890123456,
          cardType: CardType.credit,
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
          bankName: 'Banco Test',
          alias: 'Tarjeta de Crédito',
          cardholderName: 'JUAN PÉREZ',
          cardNetwork: CardNetwork.visa,
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(testCard));
        await tester.pump();

        // Assert
        expect(find.byType(GeneralCard), findsOneWidget);
        expect(find.text('Tarjeta de Crédito'), findsOneWidget);
        expect(find.text('Banco Test'), findsOneWidget);
        expect(find.text('Visa'), findsOneWidget);
        expect(find.text('Crédito'), findsOneWidget);
        expect(find.text('JUAN PÉREZ'), findsOneWidget);
        expect(find.text('•••• •••• •••• 3456'), findsOneWidget);
        expect(find.text('12/25'), findsOneWidget);
        expect(find.text('Día 15'), findsOneWidget);
        expect(find.text('Día 8'), findsOneWidget);
      },
    );

    testWidgets(
      'muestra correctamente la información de una tarjeta de débito',
      (WidgetTester tester) async {
        // Arrange
        final testCard = FinancialCard(
          id: '2',
          cardNumber: 9876543210123456,
          cardType: CardType.debit,
          expirationDate: DateTime(2026, 6),
          paymentDay: 1,
          cutOffDay: 20,
          bankName: 'Otro Banco',
          alias: 'Tarjeta de Débito',
          cardholderName: 'ANA GARCÍA',
          cardNetwork: CardNetwork.mastercard,
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(testCard));
        await tester.pump();

        // Assert
        expect(find.byType(GeneralCard), findsOneWidget);
        expect(find.text('Tarjeta de Débito'), findsOneWidget);
        expect(find.text('Otro Banco'), findsOneWidget);
        expect(find.text('MasterCard'), findsOneWidget);
        expect(find.text('Débito'), findsOneWidget);
        expect(find.text('ANA GARCÍA'), findsOneWidget);
        expect(find.text('•••• •••• •••• 3456'), findsOneWidget);
        expect(find.text('06/26'), findsOneWidget);

        // Las tarjetas de débito no muestran días de pago y corte
        expect(find.text('Día 1'), findsNothing);
        expect(find.text('Día 20'), findsNothing);
      },
    );

    testWidgets('no muestra alias si está vacío', (WidgetTester tester) async {
      // Arrange
      final testCard = FinancialCard(
        id: '3',
        cardNumber: 1234567890123456,
        cardType: CardType.credit,
        expirationDate: DateTime(2025, 12),
        paymentDay: 15,
        cutOffDay: 8,
        bankName: 'Banco Test',
        alias: '', // Alias vacío
        cardholderName: 'JUAN PÉREZ',
        cardNetwork: CardNetwork.visa,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testCard));
      await tester.pump();

      // Assert
      // Verifica que el texto del alias no aparece
      expect(find.text(''), findsNothing);

      // Pero el resto de la información debe estar presente
      expect(find.text('Banco Test'), findsOneWidget);
      expect(find.text('JUAN PÉREZ'), findsOneWidget);
    });

    testWidgets(
      'muestra "TITULAR NO ESPECIFICADO" si el nombre del titular está vacío',
      (WidgetTester tester) async {
        // Arrange
        final testCard = FinancialCard(
          id: '4',
          cardNumber: 1234567890123456,
          cardType: CardType.credit,
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
          bankName: 'Banco Test',
          alias: 'Tarjeta de Crédito',
          cardholderName: '', // Nombre del titular vacío
          cardNetwork: CardNetwork.visa,
        );

        // Act
        await tester.pumpWidget(createWidgetUnderTest(testCard));
        await tester.pump();

        // Assert
        expect(find.text('TITULAR NO ESPECIFICADO'), findsOneWidget);
      },
    );

    testWidgets('muestra los últimos 4 dígitos del número de tarjeta', (
      WidgetTester tester,
    ) async {
      // Arrange - Tarjeta con número diferente
      final testCard = FinancialCard(
        id: '5',
        cardNumber: 5432123456789876,
        cardType: CardType.credit,
        expirationDate: DateTime(2025, 12),
        paymentDay: 15,
        cutOffDay: 8,
        bankName: 'Banco Test',
        alias: 'Tarjeta de Crédito',
        cardholderName: 'JUAN PÉREZ',
        cardNetwork: CardNetwork.visa,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testCard));
      await tester.pump();

      // Assert - Verifica que solo se muestren los últimos 4 dígitos
      expect(find.text('•••• •••• •••• 9876'), findsOneWidget);
    });
  });
}
