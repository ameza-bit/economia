import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:economia/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba de integración para el flujo de tarjetas', () {
    testWidgets('Navegar a la lista de tarjetas y crear una nueva tarjeta', (
      WidgetTester tester,
    ) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla inicial
      expect(find.text('Home'), findsOneWidget);

      // Encontrar el botón de navegación a tarjetas y pulsarlo
      final cardButton = find.byIcon(Icons.credit_card);
      expect(cardButton, findsOneWidget);
      await tester.tap(cardButton);
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de lista de tarjetas
      expect(find.text('Mis Tarjetas'), findsOneWidget);

      // Inicialmente debería mostrar un estado vacío
      expect(find.text('Sin Tarjetas'), findsOneWidget);
      expect(
        find.text('No has registrado ninguna tarjeta todavía'),
        findsOneWidget,
      );

      // Pulsar el botón de añadir tarjeta
      final addButton = find.byType(FloatingActionButton);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de formulario de tarjeta
      expect(find.text('Registrar Tarjeta'), findsOneWidget);

      // Rellenar el formulario
      // 1. Alias
      final aliasField = find.widgetWithText(
        TextFormField,
        'Alias de la Tarjeta',
      );
      await tester.enterText(aliasField, 'Mi Tarjeta de Prueba');

      // 2. Número de Tarjeta
      final cardNumberField = find.widgetWithText(
        TextFormField,
        'Número de Tarjeta',
      );
      await tester.enterText(cardNumberField, '1234567890123456');

      // 3. Titular de la Tarjeta
      final cardholderField = find.widgetWithText(
        TextFormField,
        'Titular de la Tarjeta',
      );
      await tester.enterText(cardholderField, 'USUARIO DE PRUEBA');

      // 4. Seleccionar Red de la Tarjeta (visa por defecto)

      // 5. Seleccionar Tipo de Tarjeta (crédito por defecto)

      // 6. Banco
      final bankField = find.widgetWithText(TextFormField, 'Banco');
      await tester.enterText(bankField, 'Banco de Prueba');

      // No modificamos fecha de expiración, día de pago ni de corte (valores por defecto)

      // Guardar la tarjeta
      final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Tarjeta');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verificar que volvimos a la lista de tarjetas
      expect(find.text('Mis Tarjetas'), findsOneWidget);

      // Verificar que ahora se muestra la tarjeta
      expect(find.text('Mi Tarjeta de Prueba'), findsOneWidget);
      expect(find.text('Banco de Prueba'), findsOneWidget);
      expect(find.text('USUARIO DE PRUEBA'), findsOneWidget);
      expect(find.text('•••• •••• •••• 3456'), findsOneWidget);

      // Opcional: verificar que ya no se muestra el estado vacío
      expect(find.text('Sin Tarjetas'), findsNothing);
      expect(
        find.text('No has registrado ninguna tarjeta todavía'),
        findsNothing,
      );
    });
  });
}
