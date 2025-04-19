import 'dart:async';

import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_form_state.dart';
import 'package:economia/ui/views/cards/card_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definir los mocks directamente con Mocktail
class MockCardRepository extends Mock implements CardRepository {}

class MockCardFormBloc extends Mock implements CardFormBloc {}

void main() {
  late MockCardFormBloc mockCardFormBloc;

  setUp(() {
    mockCardFormBloc = MockCardFormBloc();

    // Registrar fallbacks para cualquier tipo que pueda ser usado en any()
    registerFallbackValue(CardFormUpdateCardNumberEvent(''));
    registerFallbackValue(CardFormUpdateBankNameEvent(''));
    registerFallbackValue(CardFormUpdateCardholderNameEvent(''));
    registerFallbackValue(CardFormSaveEvent());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CardFormBloc>.value(
        value: mockCardFormBloc,
        child: const CardFormView(),
      ),
    );
  }

  group('CardFormView', () {
    testWidgets(
      'muestra CircularProgressIndicator cuando el estado es CardFormLoadingState',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockCardFormBloc.state).thenReturn(CardFormLoadingState());
        when(() => mockCardFormBloc.stream).thenAnswer((_) => Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'muestra el formulario cuando el estado es CardFormReadyState',
      (WidgetTester tester) async {
        // Arrange
        final readyState = CardFormReadyState(
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
        );

        when(() => mockCardFormBloc.state).thenReturn(readyState);
        when(
          () => mockCardFormBloc.stream,
        ).thenAnswer((_) => Stream.value(readyState));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(
          find.text('Registrar Tarjeta'),
          findsNothing,
        ); // Este texto está en la AppBar que no está en la view
        expect(find.text('Alias de la Tarjeta'), findsOneWidget);
        expect(find.text('Número de Tarjeta'), findsOneWidget);
        expect(find.text('Titular de la Tarjeta'), findsOneWidget);
        expect(find.text('Red de la Tarjeta'), findsOneWidget);
        expect(find.text('Tipo de Tarjeta'), findsOneWidget);
        expect(find.text('Banco'), findsOneWidget);
        expect(find.text('Fecha de Expiración (Mes/Año)'), findsOneWidget);
        expect(find.text('Día de Pago'), findsOneWidget);
        expect(find.text('Día de Corte'), findsOneWidget);
        expect(find.text('Guardar Tarjeta'), findsOneWidget);
      },
    );

    testWidgets(
      'actualiza el número de tarjeta cuando el usuario escribe en el campo',
      (WidgetTester tester) async {
        // Arrange
        final readyState = CardFormReadyState(
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
        );

        when(() => mockCardFormBloc.state).thenReturn(readyState);
        when(
          () => mockCardFormBloc.stream,
        ).thenAnswer((_) => Stream.value(readyState));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Encontrar el campo de número de tarjeta
        final cardNumberField = find.widgetWithText(
          TextFormField,
          'Número de Tarjeta',
        );
        expect(cardNumberField, findsOneWidget);

        // Escribir en el campo
        await tester.enterText(cardNumberField, '1234567890123456');
        await tester.pump();

        // Assert - Verificar que se llamó al bloc con el evento correcto
        verify(
          () => mockCardFormBloc.add(any()),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'actualiza el nombre del banco cuando el usuario escribe en el campo',
      (WidgetTester tester) async {
        // Arrange
        final readyState = CardFormReadyState(
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
        );

        when(() => mockCardFormBloc.state).thenReturn(readyState);
        when(
          () => mockCardFormBloc.stream,
        ).thenAnswer((_) => Stream.value(readyState));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Encontrar el campo de banco
        final bankNameField = find.widgetWithText(TextFormField, 'Banco');
        expect(bankNameField, findsOneWidget);

        // Escribir en el campo
        await tester.enterText(bankNameField, 'Banco Test');
        await tester.pump();

        // Assert
        verify(
          () => mockCardFormBloc.add(any()),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets(
      'actualiza el nombre del titular cuando el usuario escribe en el campo',
      (WidgetTester tester) async {
        // Arrange
        final readyState = CardFormReadyState(
          expirationDate: DateTime(2025, 12),
          paymentDay: 15,
          cutOffDay: 8,
        );

        when(() => mockCardFormBloc.state).thenReturn(readyState);
        when(
          () => mockCardFormBloc.stream,
        ).thenAnswer((_) => Stream.value(readyState));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Encontrar el campo de titular
        final cardholderNameField = find.widgetWithText(
          TextFormField,
          'Titular de la Tarjeta',
        );
        expect(cardholderNameField, findsOneWidget);

        // Escribir en el campo
        await tester.enterText(cardholderNameField, 'Juan Pérez');
        await tester.pump();

        // Assert
        verify(
          () => mockCardFormBloc.add(any()),
        ).called(greaterThanOrEqualTo(1));
      },
    );

    testWidgets('guarda la tarjeta cuando se presiona el botón de guardar', (
      WidgetTester tester,
    ) async {
      // Arrange
      final readyState = CardFormReadyState(
        cardNumber: '1234567890123456',
        bankName: 'Banco Test',
        cardholderName: 'Juan Pérez',
        expirationDate: DateTime(2025, 12),
        paymentDay: 15,
        cutOffDay: 8,
      );

      when(() => mockCardFormBloc.state).thenReturn(readyState);
      when(
        () => mockCardFormBloc.stream,
      ).thenAnswer((_) => Stream.value(readyState));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Encontrar y presionar el botón de guardar
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Tarjeta');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);
      await tester.pump();

      // Assert
      verify(() => mockCardFormBloc.add(any())).called(greaterThanOrEqualTo(1));
    });

    testWidgets('muestra SnackBar cuando hay un error al guardar', (
      WidgetTester tester,
    ) async {
      // Arrange
      final readyState = CardFormReadyState(
        expirationDate: DateTime(2025, 12),
        paymentDay: 15,
        cutOffDay: 8,
      );

      when(() => mockCardFormBloc.state).thenReturn(readyState);

      // Crear un stream que emite primero el estado listo y luego un error
      final controller = StreamController<CardFormState>();
      controller.add(readyState);
      controller.add(CardFormErrorState("Error al guardar la tarjeta"));

      when(() => mockCardFormBloc.stream).thenAnswer((_) => controller.stream);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Simular que se recibe el estado de error
      await tester.pump();
      await tester.pump(
        const Duration(seconds: 1),
      ); // Para que aparezca el SnackBar

      // Assert
      expect(find.text('Error al guardar la tarjeta'), findsWidgets);

      // Limpiar
      controller.close();
    });
  });
}
