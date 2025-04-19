import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/ui/screens/cards/card_list_screen.dart';
import 'package:economia/ui/views/cards/card_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// Definir los mocks utilizando Mocktail
class MockCardBloc extends Mock implements CardBloc {}

class MockGoRouterProvider extends Mock implements GoRouter {}

void main() {
  late MockCardBloc mockCardBloc;

  setUp(() {
    mockCardBloc = MockCardBloc();

    // Configurar context.goNamed para simular navegación
    GoRouter.optionURLReflectsImperativeAPIs = true;

    // Registrar fallback para cuando se llamen funciones con parámetros que no coinciden exactamente
    registerFallbackValue(RefreshCardEvent());
  });

  // Crear un widget que provea el mock de CardBloc
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CardBloc>.value(
        value: mockCardBloc,
        child: const CardListScreen(),
      ),
    );
  }

  group('CardListScreen', () {
    testWidgets('construye correctamente con AppBar y CardListView', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Mis Tarjetas'), findsOneWidget);
      expect(find.byType(CardListView), findsOneWidget);
    });

    testWidgets('tiene un FloatingActionButton para agregar tarjetas', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tiene un botón de refresco en la AppBar', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('al pulsar el botón de refresco se dispara RefreshCardEvent', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Encontrar y pulsar el botón de refresco
      final refreshButton = find.byIcon(Icons.refresh);
      await tester.tap(refreshButton);
      await tester.pump();

      // Assert - Note la sintaxis de Mocktail para verify
      verify(
        () => mockCardBloc.add(any(that: isA<RefreshCardEvent>())),
      ).called(greaterThanOrEqualTo(1));
    });

    testWidgets('al iniciar la pantalla se dispara RefreshCardEvent', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockCardBloc.state).thenReturn(LoadedCardState([]));
      when(() => mockCardBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Esperar por el post frame callback

      // Assert - Verificar que se llamó al menos 1 vez (puede ser llamado durante el build y el callback)
      verify(
        () => mockCardBloc.add(any(that: isA<RefreshCardEvent>())),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
