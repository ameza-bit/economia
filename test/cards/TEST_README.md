# Tests para la Aplicación Economia

Este documento describe los tests implementados para la aplicación Economia, enfocados en la funcionalidad relacionada con tarjetas.

## Estructura de Tests

Los tests están organizados en diferentes categorías:

### Tests Unitarios

Prueban componentes individuales de forma aislada.

* `card_bloc_test.dart`: Prueba la lógica del BLoC para gestionar tarjetas
* `card_form_bloc_test.dart`: Prueba la lógica del BLoC para el formulario de tarjetas
* `card_repository_test.dart`: Prueba el repositorio que maneja la persistencia de tarjetas
* `financial_card_model_test.dart`: Prueba el modelo de datos para tarjetas
* `card_enums_test.dart`: Prueba los enumerados de tipos y redes de tarjetas

### Tests de Widgets

Prueban interfaces de usuario y su comportamiento.

* `card_form_view_test.dart`: Prueba la vista del formulario de tarjetas
* `card_list_view_test.dart`: Prueba la vista de la lista de tarjetas
* `card_item_test.dart`: Prueba el widget individual que representa una tarjeta

### Tests de Pantallas

Prueban pantallas completas y la integración de varios widgets.

* `card_list_screen_test.dart`: Prueba la pantalla de lista de tarjetas
* `card_form_screen_test.dart`: Prueba la pantalla de formulario de tarjetas

### Tests de Integración

Prueban flujos completos de la aplicación.

* `card_integration_test.dart`: Prueba el flujo completo de crear y ver tarjetas

## Cómo Ejecutar los Tests

### Tests Unitarios y de Widgets

```bash
flutter test
```

### Tests de Integración

```bash
flutter test integration_test/card_integration_test.dart
```

## Configuración de Mockito

Se incluye un archivo de configuración `setup_test.dart` para generar los mocks necesarios. Después de crear este archivo, ejecuta:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Esto generará todos los archivos mock necesarios para los tests.

## Cobertura de Tests

Los tests cubren:

* Creación, visualización y actualización de tarjetas
* Validación de formularios
* Estados de carga, vacío y error
* Navegación entre pantallas
* Persistencia de datos
* Comportamiento de los BLoCs
* Modelos de datos y enumeraciones

## Notas Adicionales

* Los tests utilizan mocks para aislar los componentes y evitar dependencias externas
* Se realizan pruebas tanto del estado inicial como de las respuestas a eventos o acciones del usuario
* Se verifica el correcto funcionamiento de la UI ante diferentes estados de la aplicación
