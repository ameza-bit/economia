import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/states/card_form_state.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Definir los mocks directamente con Mocktail
class MockCardRepository extends Mock implements CardRepository {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late CardFormBloc cardFormBloc;
  late MockCardRepository mockCardRepository;

  setUp(() {
    mockCardRepository = MockCardRepository();
    cardFormBloc = CardFormBloc(mockCardRepository);

    // Registrar fallbacks para los valores que se pasarán a métodos en verify
    registerFallbackValue(
      FinancialCard(
        id: 'test-id',
        cardNumber: 1234567890,
        cardType: CardType.credit,
        expirationDate: DateTime.now(),
        paymentDay: 15,
        cutOffDay: 8,
        bankName: 'Test Bank',
        alias: 'Test Card',
        cardholderName: 'Test User',
        cardNetwork: CardNetwork.visa,
      ),
    );
  });

  tearDown(() {
    cardFormBloc.close();
  });

  group('CardFormBloc', () {
    test('estado inicial debe ser CardFormInitialState', () {
      expect(cardFormBloc.state, isA<CardFormInitialState>());
    });

    test('CardFormInitEvent debe inicializar el formulario', () {
      // Act
      cardFormBloc.add(CardFormInitEvent());

      // Assert
      expectLater(
        cardFormBloc.stream,
        emits(
          isA<CardFormReadyState>()
              .having(
                (state) => state.cardType,
                'cardType',
                equals(CardType.credit),
              )
              .having(
                (state) => state.cardNetwork,
                'cardNetwork',
                equals(CardNetwork.visa),
              )
              .having((state) => state.cardNumber, 'cardNumber', equals(''))
              .having((state) => state.bankName, 'bankName', equals(''))
              .having((state) => state.alias, 'alias', equals(''))
              .having(
                (state) => state.cardholderName,
                'cardholderName',
                equals(''),
              ),
        ),
      );
    });

    group('Actualización de campos', () {
      setUp(() {
        // Inicializar el formulario para todos los tests de actualización
        cardFormBloc.add(CardFormInitEvent());
      });

      test(
        'CardFormUpdateCardNumberEvent debe actualizar el número de tarjeta',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act - Enviamos el evento de actualización
          cardFormBloc.add(CardFormUpdateCardNumberEvent('1234567890123456'));

          // Assert - Verificamos que el estado se actualice correctamente
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.cardNumber,
                'cardNumber',
                equals('1234567890123456'),
              ),
            ),
          );
        },
      );

      test(
        'CardFormUpdateBankNameEvent debe actualizar el nombre del banco',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act
          cardFormBloc.add(CardFormUpdateBankNameEvent('Banco Test'));

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.bankName,
                'bankName',
                equals('Banco Test'),
              ),
            ),
          );
        },
      );

      test(
        'CardFormUpdateCardTypeEvent debe actualizar el tipo de tarjeta',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act
          cardFormBloc.add(CardFormUpdateCardTypeEvent(CardType.debit));

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.cardType,
                'cardType',
                equals(CardType.debit),
              ),
            ),
          );
        },
      );

      test(
        'CardFormUpdateExpirationDateEvent debe actualizar la fecha de expiración',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act
          cardFormBloc.add(CardFormUpdateExpirationDateEvent(6, 2026));

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.expirationDate,
                'expirationDate',
                equals(DateTime(2026, 6, 1)),
              ),
            ),
          );
        },
      );

      test('CardFormUpdateAliasEvent debe actualizar el alias', () async {
        // Esperar a que el estado inicial esté listo
        await expectLater(
          cardFormBloc.stream,
          emits(isA<CardFormReadyState>()),
        );

        // Act
        cardFormBloc.add(CardFormUpdateAliasEvent('Mi Tarjeta Personal'));

        // Assert
        await expectLater(
          cardFormBloc.stream,
          emits(
            isA<CardFormReadyState>().having(
              (state) => state.alias,
              'alias',
              equals('Mi Tarjeta Personal'),
            ),
          ),
        );
      });

      test(
        'CardFormUpdateCardholderNameEvent debe actualizar el nombre del titular',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act
          cardFormBloc.add(CardFormUpdateCardholderNameEvent('Juan Pérez'));

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.cardholderName,
                'cardholderName',
                equals('Juan Pérez'),
              ),
            ),
          );
        },
      );

      test(
        'CardFormUpdateCardNetworkEvent debe actualizar la red de la tarjeta',
        () async {
          // Esperar a que el estado inicial esté listo
          await expectLater(
            cardFormBloc.stream,
            emits(isA<CardFormReadyState>()),
          );

          // Act
          cardFormBloc.add(
            CardFormUpdateCardNetworkEvent(CardNetwork.mastercard),
          );

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emits(
              isA<CardFormReadyState>().having(
                (state) => state.cardNetwork,
                'cardNetwork',
                equals(CardNetwork.mastercard),
              ),
            ),
          );
        },
      );
    });

    group('Validación y guardado', () {
      setUp(() {
        // Preparar el estado para la validación
        cardFormBloc.add(CardFormInitEvent());

        // Esperamos a que se inicialice el estado
        expectLater(cardFormBloc.stream, emits(isA<CardFormReadyState>()));
      });

      test('debe emitir error si el número de tarjeta está vacío', () async {
        // Preparar el estado
        cardFormBloc.add(CardFormUpdateBankNameEvent('Banco Test'));
        cardFormBloc.add(CardFormUpdateCardholderNameEvent('Juan Pérez'));

        // Saltar los estados de actualización
        await expectLater(
          cardFormBloc.stream,
          emitsThrough(
            isA<CardFormReadyState>()
                .having(
                  (state) => state.bankName,
                  'bankName',
                  equals('Banco Test'),
                )
                .having(
                  (state) => state.cardholderName,
                  'cardholderName',
                  equals('Juan Pérez'),
                )
                .having((state) => state.cardNumber, 'cardNumber', equals('')),
          ),
        );

        // Act - Intentar guardar
        cardFormBloc.add(CardFormSaveEvent());

        // Assert - Verificar secuencia de estados (error y vuelta al estado anterior)
        await expectLater(
          cardFormBloc.stream,
          emitsInOrder([
            isA<CardFormErrorState>().having(
              (state) => state.message,
              'message',
              contains('número de tarjeta'),
            ),
            isA<CardFormReadyState>(),
          ]),
        );
      });

      test('debe emitir error si el nombre del banco está vacío', () async {
        // Preparar el estado
        cardFormBloc.add(CardFormUpdateCardNumberEvent('1234567890123456'));
        cardFormBloc.add(CardFormUpdateCardholderNameEvent('Juan Pérez'));

        // Saltar los estados de actualización
        await expectLater(
          cardFormBloc.stream,
          emitsThrough(
            isA<CardFormReadyState>()
                .having(
                  (state) => state.cardNumber,
                  'cardNumber',
                  equals('1234567890123456'),
                )
                .having(
                  (state) => state.cardholderName,
                  'cardholderName',
                  equals('Juan Pérez'),
                )
                .having((state) => state.bankName, 'bankName', equals('')),
          ),
        );

        // Act
        cardFormBloc.add(CardFormSaveEvent());

        // Assert
        await expectLater(
          cardFormBloc.stream,
          emitsInOrder([
            isA<CardFormErrorState>().having(
              (state) => state.message,
              'message',
              contains('nombre del banco'),
            ),
            isA<CardFormReadyState>(),
          ]),
        );
      });

      test('debe emitir error si el nombre del titular está vacío', () async {
        // Preparar el estado
        cardFormBloc.add(CardFormUpdateCardNumberEvent('1234567890123456'));
        cardFormBloc.add(CardFormUpdateBankNameEvent('Banco Test'));

        // Saltar los estados de actualización
        await expectLater(
          cardFormBloc.stream,
          emitsThrough(
            isA<CardFormReadyState>()
                .having(
                  (state) => state.cardNumber,
                  'cardNumber',
                  equals('1234567890123456'),
                )
                .having(
                  (state) => state.bankName,
                  'bankName',
                  equals('Banco Test'),
                )
                .having(
                  (state) => state.cardholderName,
                  'cardholderName',
                  equals(''),
                ),
          ),
        );

        // Act
        cardFormBloc.add(CardFormSaveEvent());

        // Assert
        await expectLater(
          cardFormBloc.stream,
          emitsInOrder([
            isA<CardFormErrorState>().having(
              (state) => state.message,
              'message',
              contains('nombre del titular'),
            ),
            isA<CardFormReadyState>(),
          ]),
        );
      });

      test(
        'debe guardar la tarjeta correctamente cuando todos los campos son válidos',
        () async {
          // Preparar el estado con todos los campos válidos
          cardFormBloc.add(CardFormUpdateCardNumberEvent('1234567890123456'));
          cardFormBloc.add(CardFormUpdateBankNameEvent('Banco Test'));
          cardFormBloc.add(CardFormUpdateCardholderNameEvent('Juan Pérez'));

          // Saltar los estados de actualización
          await expectLater(
            cardFormBloc.stream,
            emitsThrough(
              isA<CardFormReadyState>()
                  .having(
                    (state) => state.cardNumber,
                    'cardNumber',
                    equals('1234567890123456'),
                  )
                  .having(
                    (state) => state.bankName,
                    'bankName',
                    equals('Banco Test'),
                  )
                  .having(
                    (state) => state.cardholderName,
                    'cardholderName',
                    equals('Juan Pérez'),
                  ),
            ),
          );

          // Act
          cardFormBloc.add(CardFormSaveEvent());

          // Assert
          await expectLater(
            cardFormBloc.stream,
            emitsInOrder([
              isA<CardFormLoadingState>(),
              isA<CardFormSuccessState>().having(
                (state) => state.message,
                'message',
                contains('guardada correctamente'),
              ),
            ]),
          );

          // Verificar que el repositorio fue llamado correctamente
          verify(() => mockCardRepository.addCardLocal(any())).called(1);
        },
      );
    });
  });
}
