import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/blocs/recurring_payment_form_bloc.dart';
import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/enums/week_day.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/events/recurring_payment_form_event.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/data/states/recurring_payment_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecurringPaymentFormView extends StatefulWidget {
  final bool isEditing;
  final String? paymentId;

  const RecurringPaymentFormView({
    super.key,
    this.isEditing = false,
    this.paymentId,
  });

  @override
  State<RecurringPaymentFormView> createState() =>
      _RecurringPaymentFormViewState();
}

class _RecurringPaymentFormViewState extends State<RecurringPaymentFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _providerController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _providerController = TextEditingController();
    _amountController = TextEditingController();
    _categoryController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _providerController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Método para seleccionar fechas
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final RecurringPaymentFormReadyState formState =
        context.read<RecurringPaymentFormBloc>().state
            as RecurringPaymentFormReadyState;

    final initialDate =
        isStartDate
            ? formState.startDate
            : (formState.endDate ??
                DateTime.now().add(const Duration(days: 365)));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate:
          isStartDate
              ? DateTime.now().subtract(const Duration(days: 365))
              : formState.startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      locale: const Locale('es', 'MX'),
    );

    if (selectedDate != null && context.mounted) {
      if (isStartDate) {
        context.read<RecurringPaymentFormBloc>().add(
          RecurringPaymentFormUpdateStartDateEvent(selectedDate),
        );
      } else {
        context.read<RecurringPaymentFormBloc>().add(
          RecurringPaymentFormUpdateEndDateEvent(selectedDate),
        );
      }
    }
  }

  Future<void> _selectDay(BuildContext context) async {
    final RecurringPaymentFormReadyState state =
        context.read<RecurringPaymentFormBloc>().state
            as RecurringPaymentFormReadyState;
    final initialDay = state.specificDay;

    final int? selectedDay = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempDay = initialDay;
        return AlertDialog(
          title: Text('Día de pago'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Seleccione el día del mes:'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed:
                            tempDay > 1
                                ? () => setState(() => tempDay--)
                                : null,
                      ),
                      SizedBox(width: 16),
                      Text('$tempDay', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed:
                            tempDay < 31
                                ? () => setState(() => tempDay++)
                                : null,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempDay),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (selectedDay != null && context.mounted) {
      context.read<RecurringPaymentFormBloc>().add(
        RecurringPaymentFormUpdateSpecificDayEvent(selectedDay),
      );
    }
  }

  // Método para seleccionar la posición ordinal (1er, 2do, etc.)
  Future<void> _selectWeekDayOrdinal(BuildContext context) async {
    final RecurringPaymentFormReadyState state =
        context.read<RecurringPaymentFormBloc>().state
            as RecurringPaymentFormReadyState;
    final int initialOrdinal = state.weekDayOrdinal;

    final int? selectedOrdinal = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccione la ocurrencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 5; i++)
                RadioListTile<int>(
                  title: Text(_getOrdinalText(i)),
                  value: i,
                  groupValue: initialOrdinal,
                  onChanged: (value) => Navigator.pop(context, value),
                ),
              RadioListTile<int>(
                title: Text(_getOrdinalText(-1)),
                value: -1,
                groupValue: initialOrdinal,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selectedOrdinal != null && context.mounted) {
      context.read<RecurringPaymentFormBloc>().add(
        RecurringPaymentFormUpdateWeekDayOrdinalEvent(selectedOrdinal),
      );
    }
  }

  String _getOrdinalText(int ordinal) {
    if (ordinal == -1) return 'Último';

    switch (ordinal) {
      case 1:
        return 'Primer';
      case 2:
        return 'Segundo';
      case 3:
        return 'Tercer';
      case 4:
        return 'Cuarto';
      case 5:
        return 'Quinto';
      default:
        return '$ordinal°';
    }
  }

  // Método para seleccionar el segundo día de pago quincenal
  Future<void> _selectSecondDay(BuildContext context) async {
    final RecurringPaymentFormReadyState state =
        context.read<RecurringPaymentFormBloc>().state
            as RecurringPaymentFormReadyState;
    final initialDay = state.secondSpecificDay ?? state.specificDay + 15;

    final int? selectedDay = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempDay = initialDay;
        return AlertDialog(
          title: Text('Segundo día de pago quincenal'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Seleccione el segundo día del mes:'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed:
                            tempDay > 1
                                ? () => setState(() => tempDay--)
                                : null,
                      ),
                      SizedBox(width: 16),
                      Text('$tempDay', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed:
                            tempDay < 31
                                ? () => setState(() => tempDay++)
                                : null,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempDay),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (selectedDay != null && context.mounted) {
      context.read<RecurringPaymentFormBloc>().add(
        RecurringPaymentFormUpdateSecondSpecificDayEvent(selectedDay),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Editar Pago Recurrente' : 'Nuevo Pago Recurrente',
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RecurringPaymentFormBloc, RecurringPaymentFormState>(
        listener: (context, state) {
          if (state is RecurringPaymentFormSuccessState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);

            // Intentar refrescar la lista después de volver a la pantalla principal
            Future.delayed(Duration.zero, () {
              try {
                if (context.mounted) {
                  BlocProvider.of<RecurringPaymentBloc>(
                    context,
                    listen: false,
                  ).add(RefreshRecurringPaymentEvent());
                }
              } catch (e) {
                debugPrint('Error al refrescar después de navegar: $e');
              }
            });
          } else if (state is RecurringPaymentFormErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RecurringPaymentFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecurringPaymentFormReadyState) {
            // Actualizar controladores con los valores del estado
            _nameController.text = state.name;
            _descriptionController.text = state.description;
            _providerController.text = state.provider;
            _amountController.text = state.amount;
            _categoryController.text = state.category;

            bool showSecondDaySelector =
                state.recurrenceType == RecurrenceType.biweekly &&
                state.paymentDateType == PaymentDateType.specificDay;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Nombre del pago recurrente
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Pago *',
                        hintText: 'Ej: Electricidad, Colegiatura, Gimnasio',
                        border: OutlineInputBorder(),
                        helperText: 'Nombre descriptivo del pago',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged:
                          (value) => context
                              .read<RecurringPaymentFormBloc>()
                              .add(RecurringPaymentFormUpdateNameEvent(value)),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción (opcional)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Detalles adicionales sobre este pago',
                        border: OutlineInputBorder(),
                        helperText: 'Información adicional',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged:
                          (value) =>
                              context.read<RecurringPaymentFormBloc>().add(
                                RecurringPaymentFormUpdateDescriptionEvent(
                                  value,
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Proveedor o acreedor
                    TextFormField(
                      controller: _providerController,
                      decoration: const InputDecoration(
                        labelText: 'Proveedor/Acreedor *',
                        hintText: 'Ej: CFE, Universidad, Smart Fit',
                        border: OutlineInputBorder(),
                        helperText: 'Entidad a la que se realiza el pago',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged:
                          (value) =>
                              context.read<RecurringPaymentFormBloc>().add(
                                RecurringPaymentFormUpdateProviderEvent(value),
                              ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El proveedor es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría (opcional)
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Categoría (opcional)',
                        hintText: 'Ej: Servicios, Educación, Salud',
                        border: OutlineInputBorder(),
                        helperText: 'Tipo de gasto',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged:
                          (value) =>
                              context.read<RecurringPaymentFormBloc>().add(
                                RecurringPaymentFormUpdateCategoryEvent(value),
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Monto
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto *',
                        hintText: 'Ej: 1500.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                        helperText: 'Cantidad del pago',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      onChanged:
                          (value) =>
                              context.read<RecurringPaymentFormBloc>().add(
                                RecurringPaymentFormUpdateAmountEvent(value),
                              ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El monto es obligatorio';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Ingrese un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de tarjeta (opcional)
                    BlocBuilder<CardBloc, CardState>(
                      builder: (context, cardState) {
                        if (cardState is LoadedCardState) {
                          if (cardState.cards.isEmpty) {
                            return Card(
                              color: Colors.amber.shade100,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Sin tarjetas registradas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'No es obligatorio asociar una tarjeta',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return DropdownButtonFormField<String?>(
                            decoration: const InputDecoration(
                              labelText: 'Tarjeta (opcional)',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Tarjeta con la que se realizará el pago',
                            ),
                            value: state.selectedCard?.id,
                            items: [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Ninguna / Efectivo'),
                              ),
                              ...cardState.cards.map((card) {
                                String displayText =
                                    card.alias.isNotEmpty
                                        ? '${card.alias} - ${card.bankName}'
                                        : '${card.bankName} - ****${card.cardNumber.toString().substring(card.cardNumber.toString().length - 4)}';

                                return DropdownMenuItem<String?>(
                                  value: card.id,
                                  child: Text(displayText),
                                );
                              }),
                            ],
                            onChanged: (String? cardId) {
                              if (cardId == null) {
                                context.read<RecurringPaymentFormBloc>().add(
                                  RecurringPaymentFormUpdateSelectedCardEvent(
                                    null,
                                  ),
                                );
                              } else {
                                final selectedCard = cardState.cards.firstWhere(
                                  (card) => card.id == cardId,
                                );
                                context.read<RecurringPaymentFormBloc>().add(
                                  RecurringPaymentFormUpdateSelectedCardEvent(
                                    selectedCard,
                                  ),
                                );
                              }
                            },
                          );
                        }

                        return const SizedBox(
                          height: 60,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fechas de inicio y fin
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha inicio *',
                                border: OutlineInputBorder(),
                                helperText: 'Inicio del pago',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                      'es_MX',
                                    ).format(state.startDate),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  const Icon(Icons.calendar_today, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha fin (opcional)',
                                border: OutlineInputBorder(),
                                helperText: 'Fin del pago',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.endDate != null
                                        ? DateFormat(
                                          'dd/MM/yyyy',
                                          'es_MX',
                                        ).format(state.endDate!)
                                        : 'No definida',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (state.endDate != null)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed:
                                              () => context
                                                  .read<
                                                    RecurringPaymentFormBloc
                                                  >()
                                                  .add(
                                                    RecurringPaymentFormUpdateEndDateEvent(
                                                      null,
                                                    ),
                                                  ),
                                        ),
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tipo de recurrencia
                    DropdownButtonFormField<RecurrenceType>(
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia de Pago *',
                        border: OutlineInputBorder(),
                        helperText: 'Cada cuánto se realiza el pago',
                      ),
                      value: state.recurrenceType,
                      items:
                          RecurrenceType.values.map((type) {
                            return DropdownMenuItem<RecurrenceType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<RecurringPaymentFormBloc>().add(
                            RecurringPaymentFormUpdateRecurrenceTypeEvent(
                              value,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de fecha de pago (día específico o día de la semana)
                    DropdownButtonFormField<PaymentDateType>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Fecha de Pago *',
                        border: OutlineInputBorder(),
                        helperText: 'Cómo se determina el día de pago',
                      ),
                      value: state.paymentDateType,
                      items:
                          PaymentDateType.values.map((type) {
                            return DropdownMenuItem<PaymentDateType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<RecurringPaymentFormBloc>().add(
                            RecurringPaymentFormUpdatePaymentDateTypeEvent(
                              value,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Configuración de fecha según el tipo seleccionado
                    if (state.paymentDateType == PaymentDateType.specificDay)
                      // Día específico del mes
                      GestureDetector(
                        onTap: () => _selectDay(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Día del Mes *',
                            border: OutlineInputBorder(),
                            helperText:
                                'Día específico en que se realiza el pago',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Día ${state.specificDay}',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.edit_calendar),
                            ],
                          ),
                        ),
                      ),

                    // Añadir el selector de segundo día para pagos quincenales
                    if (showSecondDaySelector) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectSecondDay(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Segundo Día de Pago Quincenal *',
                            border: OutlineInputBorder(),
                            helperText:
                                'Segundo día específico para pagos quincenales',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                state.secondSpecificDay != null
                                    ? 'Día ${state.secondSpecificDay}'
                                    : 'Seleccione el segundo día',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.edit_calendar),
                            ],
                          ),
                        ),
                      ),

                      // Mensaje informativo para pagos quincenales
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Para pagos quincenales, se realizará un pago el día ${state.specificDay} y otro el día ${state.secondSpecificDay ?? "..."} de cada mes.',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    if (state.paymentDateType == PaymentDateType.weekDay)
                      // Selección de día de la semana y ordinal
                      Column(
                        children: [
                          // Día de la semana
                          DropdownButtonFormField<WeekDay>(
                            decoration: const InputDecoration(
                              labelText: 'Día de la Semana *',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Qué día de la semana se realiza el pago',
                            ),
                            value: state.weekDay ?? WeekDay.monday,
                            items:
                                WeekDay.values.map((day) {
                                  return DropdownMenuItem<WeekDay>(
                                    value: day,
                                    child: Text(day.displayName),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<RecurringPaymentFormBloc>().add(
                                  RecurringPaymentFormUpdateWeekDayEvent(value),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Ordinal (1er, 2do, etc. o último)
                          GestureDetector(
                            onTap: () => _selectWeekDayOrdinal(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Ocurrencia *',
                                border: OutlineInputBorder(),
                                helperText:
                                    'Qué ocurrencia del día seleccionado',
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getOrdinalText(state.weekDayOrdinal),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const Icon(Icons.edit),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    if (state.paymentDateType == PaymentDateType.lastDayOfMonth)
                      // Mensaje informativo para último día del mes
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'El pago se realizará el último día de cada periodo (mes, trimestre, etc.)',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Estado activo/inactivo
                    SwitchListTile(
                      title: Text('Estado del Pago'),
                      subtitle: Text(state.isActive ? 'Activo' : 'Inactivo'),
                      value: state.isActive,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        context.read<RecurringPaymentFormBloc>().add(
                          RecurringPaymentFormUpdateIsActiveEvent(value),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Leyenda de campos obligatorios
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        '* Campos obligatorios',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    // Botón de guardar
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<RecurringPaymentFormBloc>().add(
                            RecurringPaymentFormSaveEvent(
                              context: context,
                              isEditing: widget.isEditing,
                              paymentId: widget.paymentId,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.isEditing ? 'Actualizar Pago' : 'Guardar Pago',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Cargando...'));
        },
      ),
    );
  }
}
