import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/events/card_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definir el mock de CardRepository con Mocktail
class MockCardRepository extends Mock implements CardRepository {}

void main() {
  late CardBloc cardBloc;
  late MockCardRepository mockCardRepository;

  setUp(() {
    mockCardRepository = MockCardRepository();
    cardBloc = CardBloc(repository: mockCardRepository);
  });

  tearDown(() {
    cardBloc.close();
  });

  group('CardBloc', () {
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

    test('estado inicial debe ser InitialCardState', () {
      expect(cardBloc.state, isA<InitialCardState>());
    });

    test(
      'emite [LoadingCardState, LoadedCardState] cuando LoadCardEvent es agregado',
      () {
        // Arrange
        when(() => mockCardRepository.getCardsLocal()).thenReturn(testCards);

        // Act & Assert
        expectLater(
          cardBloc.stream,
          emitsInOrder([
            isA<LoadingCardState>(),
            isA<LoadedCardState>().having(
              (state) => state.cards,
              'cards',
              equals(testCards),
            ),
          ]),
        );

        cardBloc.add(LoadCardEvent());
      },
    );

    test(
      'emite [LoadingCardState, ErrorCardState] cuando hay un error al cargar tarjetas',
      () {
        // Arrange
        when(
          () => mockCardRepository.getCardsLocal(),
        ).thenThrow(Exception('Error de prueba'));

        // Act & Assert
        expectLater(
          cardBloc.stream,
          emitsInOrder([
            isA<LoadingCardState>(),
            isA<ErrorCardState>().having(
              (state) => state.message,
              'message',
              contains('Error loading cards'),
            ),
          ]),
        );

        cardBloc.add(LoadCardEvent());
      },
    );

    test(
      'emite [LoadingCardState, LoadedCardState] cuando RefreshCardEvent es agregado',
      () {
        // Arrange
        when(() => mockCardRepository.getCardsLocal()).thenReturn(testCards);

        // Act & Assert
        expectLater(
          cardBloc.stream,
          emitsInOrder([
            isA<LoadingCardState>(),
            isA<LoadedCardState>().having(
              (state) => state.cards,
              'cards',
              equals(testCards),
            ),
          ]),
        );

        cardBloc.add(RefreshCardEvent());
      },
    );
  });
}
