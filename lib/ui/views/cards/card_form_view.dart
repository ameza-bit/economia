import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/states/card_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardFormView extends StatefulWidget {
  const CardFormView({super.key});

  @override
  State<CardFormView> createState() => _CardFormViewState();
}

class _CardFormViewState extends State<CardFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _aliasController;
  late TextEditingController _cardholderNameController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _aliasController = TextEditingController();
    _cardholderNameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _bankNameController.dispose();
    _aliasController.dispose();
    _cardholderNameController.dispose();
    super.dispose();
  }

  // Métodos existentes para seleccionar fecha y día
  Future<void> _selectMonthYear(BuildContext context) async {
    // Código existente sin cambios...
    final state = context.read<CardFormBloc>().state as CardFormReadyState;
    final initialDate = state.expirationDate;

    final Map<String, int>? result = await showDialog<Map<String, int>>(
      context: context,
      builder: (BuildContext context) {
        int selectedMonth = initialDate.month;
        int selectedYear = initialDate.year;

        return AlertDialog(
          title: Text('Fecha de Expiración'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de mes
                  Row(
                    children: [
                      Text('Mes: '),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedMonth,
                          items:
                              List.generate(12, (index) => index + 1)
                                  .map(
                                    (month) => DropdownMenuItem<int>(
                                      value: month,
                                      child: Text('$month'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedMonth = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Selector de año
                  Row(
                    children: [
                      Text('Año: '),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selectedYear,
                          items:
                              List.generate(
                                    10,
                                    (index) => DateTime.now().year + index,
                                  )
                                  .map(
                                    (year) => DropdownMenuItem<int>(
                                      value: year,
                                      child: Text('$year'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedYear = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed:
                  () => Navigator.of(
                    context,
                  ).pop({'month': selectedMonth, 'year': selectedYear}),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (result != null && context.mounted) {
      context.read<CardFormBloc>().add(
        CardFormUpdateExpirationDateEvent(result['month']!, result['year']!),
      );
    }
  }

  Future<void> _selectDay(BuildContext context, bool isPaymentDay) async {
    // Código existente sin cambios...
    final CardFormReadyState state =
        context.read<CardFormBloc>().state as CardFormReadyState;
    final initialDay = isPaymentDay ? state.paymentDay : state.cutOffDay;

    final int? selectedDay = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempDay = initialDay;
        return AlertDialog(
          title: Text(isPaymentDay ? 'Día de pago' : 'Día de corte'),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(tempDay),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (selectedDay != null && context.mounted) {
      if (isPaymentDay) {
        context.read<CardFormBloc>().add(
          CardFormUpdatePaymentDayEvent(selectedDay),
        );
      } else {
        context.read<CardFormBloc>().add(
          CardFormUpdateCutOffDayEvent(selectedDay),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Tarjeta'), centerTitle: true),
      body: BlocConsumer<CardFormBloc, CardFormState>(
        listener: (context, state) {
          if (state is CardFormSuccessState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          } else if (state is CardFormErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, CardFormState state) {
          if (state is CardFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CardFormReadyState) {
            // Actualizar los controladores de texto con los valores del estado
            _cardNumberController.text = state.cardNumber;
            _bankNameController.text = state.bankName;
            _aliasController.text = state.alias;
            _cardholderNameController.text = state.cardholderName;

            // Verificar si mostrar campos específicos para tarjetas de crédito
            bool isCredit =
                state.cardType == CardType.credit ||
                state.cardType == CardType.other;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Campo de alias (nuevo)
                    TextFormField(
                      controller: _aliasController,
                      decoration: const InputDecoration(
                        labelText: 'Alias de la Tarjeta',
                        hintText: 'Ej: Tarjeta Personal, Tarjeta de Trabajo',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          (value) => context.read<CardFormBloc>().add(
                            CardFormUpdateAliasEvent(value),
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Campo de número de tarjeta (existente)
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Tarjeta',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged:
                          (value) => context.read<CardFormBloc>().add(
                            CardFormUpdateCardNumberEvent(value),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el número de tarjeta';
                        } else if (value.length < 4) {
                          return 'El número de tarjeta debe tener al menos 4 caracteres';
                        } else if (value.length > 16) {
                          return 'El número de tarjeta no puede tener más de 16 caracteres';
                        } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'El número de tarjeta solo puede contener dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de titular de la tarjeta (nuevo)
                    TextFormField(
                      controller: _cardholderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Titular de la Tarjeta',
                        hintText: 'Nombre como aparece en la tarjeta',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          (value) => context.read<CardFormBloc>().add(
                            CardFormUpdateCardholderNameEvent(value),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de red de tarjeta (nuevo)
                    DropdownButtonFormField<CardNetwork>(
                      decoration: const InputDecoration(
                        labelText: 'Red de la Tarjeta',
                        border: OutlineInputBorder(),
                      ),
                      value: state.cardNetwork,
                      items:
                          CardNetwork.values.map((CardNetwork network) {
                            return DropdownMenuItem<CardNetwork>(
                              value: network,
                              child: Text(network.displayName),
                            );
                          }).toList(),
                      onChanged: (CardNetwork? newValue) {
                        if (newValue != null) {
                          context.read<CardFormBloc>().add(
                            CardFormUpdateCardNetworkEvent(newValue),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de tipo de tarjeta (existente)
                    DropdownButtonFormField<CardType>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Tarjeta',
                        border: OutlineInputBorder(),
                      ),
                      value: state.cardType,
                      items:
                          CardType.values.map((CardType type) {
                            return DropdownMenuItem<CardType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                      onChanged: (CardType? newValue) {
                        if (newValue != null) {
                          context.read<CardFormBloc>().add(
                            CardFormUpdateCardTypeEvent(newValue),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de banco (existente)
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Banco',
                        border: OutlineInputBorder(),
                      ),
                      onChanged:
                          (value) => context.read<CardFormBloc>().add(
                            CardFormUpdateBankNameEvent(value),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del banco';
                        } else if (value.length < 3) {
                          return 'El nombre del banco debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de mes/año para fecha de expiración (existente)
                    GestureDetector(
                      onTap: () => _selectMonthYear(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de Expiración (Mes/Año)',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.expirationDate.month}/${state.expirationDate.year}',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campos específicos para tarjetas de crédito
                    if (isCredit) ...[
                      // Selector de día para fecha de pago
                      GestureDetector(
                        onTap: () => _selectDay(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Día de Pago',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Día ${state.paymentDay}',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Selector de día para fecha de corte
                      GestureDetector(
                        onTap: () => _selectDay(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Día de Corte',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Día ${state.cutOffDay}',
                                style: TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Botón de guardar (existente)
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<CardFormBloc>().add(
                            CardFormSaveEvent(context: context),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Guardar Tarjeta'),
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
