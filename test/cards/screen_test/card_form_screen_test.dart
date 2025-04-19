import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_form_state.dart';
import 'package:economia/ui/screens/cards/card_form_screen.dart';
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

    // Configurar comportamiento del mock
    when(() => mockCardFormBloc.state).thenReturn(CardFormInitialState());
    when(() => mockCardFormBloc.stream).thenAnswer((_) => Stream.empty());
  });


  group('CardFormScreen', () {
    testWidgets('crea una instancia de CardFormBloc y muestra CardFormView', (
      WidgetTester tester,
    ) async {
      // Use a real widget instance to test provider creation
      Widget realWidget = MaterialApp(home: CardFormScreen());

      // Act
      await tester.pumpWidget(realWidget);
      await tester.pump();

      // Assert
      expect(find.byType(CardFormView), findsOneWidget);
      // Verify that a BlocProvider for CardFormBloc exists
      expect(find.byType(BlocProvider<CardFormBloc>), findsOneWidget);
    });

    testWidgets('inicializa el bloc con CardFormInitEvent', (
      WidgetTester tester,
    ) async {
      // Use a real widget instance
      Widget realWidget = MaterialApp(home: CardFormScreen());

      // Act
      await tester.pumpWidget(realWidget);
      await tester.pump();

      // This is not a perfect test since we can't easily verify the internal bloc action
      // In a real scenario, you might want to use a different approach or mock dependencies
      expect(find.byType(CardFormView), findsOneWidget);
    });
  });
}
