import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/ui/views/cards/card_list_view.dart';
import 'package:economia/ui/widgets/cards/card_item.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definir el mock utilizando Mocktail
class MockCardBloc extends Mock implements CardBloc {}

void main() {
  late MockCardBloc mockCardBloc;

  setUp(() {
    mockCardBloc = MockCardBloc();

    // Registrar fallback para RefreshCardEvent
    registerFallbackValue(RefreshCardEvent());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CardBloc>.value(
        value: mockCardBloc,
        child: Scaffold(body: CardListView()),
      ),
    );
  }

  group('CardListView', () {
    final List<FinancialCard> testCards = [
      FinancialCard(
        id: '1',
        cardNumber: 1234,
        cardType: CardType.credit,
        expirationDate: DateTime(2025, 12),
        paymentDay: 15,
        cutOffDay: 8,
        bankName: 'Banco Test',
        alias: 'Tarjeta Test',
        cardholderName: 'Usuario Test',
        cardNetwork: CardNetwork.visa,
      ),
      FinancialCard(
        id: '2',
        cardNumber: 5678,
        cardType: CardType.debit,
        expirationDate: DateTime(2026, 6),
        paymentDay: 1,
        cutOffDay: 25,
        bankName: 'Otro Banco',
        alias: 'Débito Personal',
        cardholderName: 'Usuario Test',
        cardNetwork: CardNetwork.mastercard,
      ),
    ];

    testWidgets(
      'muestra mensaje de carga cuando el estado es LoadingCardState',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockCardBloc.state).thenReturn(LoadingCardState());
        when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Cargando tarjetas...'), findsOneWidget);
      },
    );

    testWidgets('muestra un estado vacío cuando no hay tarjetas', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Sin Tarjetas'), findsOneWidget);
      expect(
        find.text('No has registrado ninguna tarjeta todavía'),
        findsOneWidget,
      );
    });

    testWidgets(
      'muestra una lista de tarjetas cuando hay tarjetas disponibles',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockCardBloc.state).thenReturn(LoadedCardState(testCards));
        when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(CardItem), findsNWidgets(2));
        expect(find.text('Banco Test'), findsOneWidget);
        expect(find.text('Otro Banco'), findsOneWidget);
      },
    );

    testWidgets(
      'muestra mensaje de error cuando hay un error al cargar tarjetas',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockCardBloc.state,
        ).thenReturn(ErrorCardState('Error al cargar las tarjetas'));
        when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(EmptyState), findsOneWidget);
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Error al cargar las tarjetas'), findsOneWidget);
      },
    );

    testWidgets(
      'llama a RefreshCardEvent cuando se presiona el botón de reintentar',
      (WidgetTester tester) async {
        // Arrange
        when(
          () => mockCardBloc.state,
        ).thenReturn(ErrorCardState('Error al cargar las tarjetas'));
        when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Encontrar y presionar el botón de reintentar
        final retryButton = find.text('Reintentar');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pump();

        // Assert
        verify(
          () => mockCardBloc.add(any(that: isA<RefreshCardEvent>())),
        ).called(1);
      },
    );
  });
}
