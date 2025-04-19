import 'package:economia/data/blocs/card_bloc.dart';
import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/blocs/concept_form_bloc.dart';
import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/events/concept_form_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/states/card_state.dart';
import 'package:economia/data/states/concept_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptFormView extends StatefulWidget {
  final bool isEditing;
  final int? conceptId;

  const ConceptFormView({super.key, this.isEditing = false, this.conceptId});

  @override
  State<ConceptFormView> createState() => _ConceptFormViewState();
}

class _ConceptFormViewState extends State<ConceptFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _storeController;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _storeController = TextEditingController();
    _totalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _storeController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Concepto' : 'Nuevo Concepto'),
        centerTitle: true,
      ),
      body: BlocConsumer<ConceptFormBloc, ConceptFormState>(
        listener: (context, state) {
          if (state is ConceptFormSuccessState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            // Cerrar la pantalla de formulario
            Navigator.pop(context);

            // Intentar refrescar la lista después de volver a la pantalla principal
            Future.delayed(Duration.zero, () {
              try {
                if (context.mounted) {
                  BlocProvider.of<ConceptBloc>(
                    context,
                    listen: false,
                  ).add(RefreshConceptEvent());
                }
              } catch (e) {
                // Si fallara, no afecta la experiencia del usuario
                debugPrint('Error al refrescar después de navegar: $e');
              }
            });
          } else if (state is ConceptFormErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },

        builder: (context, state) {
          if (state is ConceptFormLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConceptFormReadyState) {
            // Actualizar controladores con los valores del estado
            _nameController.text = state.name;
            _descriptionController.text = state.description;
            _storeController.text = state.store;
            _totalController.text = state.total;

            // Determinar si mostrar selector de meses
            final bool showMonthsSelector =
                state.paymentMode != PaymentMode.oneTime;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Nombre del concepto
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Concepto *',
                        hintText: 'Ej: Televisor, Refrigerador, Renta',
                        border: OutlineInputBorder(),
                        helperText: 'Nombre descriptivo del gasto',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged:
                          (value) => context.read<ConceptFormBloc>().add(
                            ConceptFormUpdateNameEvent(value),
                          ),
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
                        hintText: 'Detalles adicionales sobre este gasto',
                        border: OutlineInputBorder(),
                        helperText: 'Información adicional',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged:
                          (value) => context.read<ConceptFormBloc>().add(
                            ConceptFormUpdateDescriptionEvent(value),
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Tienda o establecimiento
                    TextFormField(
                      controller: _storeController,
                      decoration: const InputDecoration(
                        labelText: 'Tienda/Establecimiento *',
                        hintText: 'Ej: Amazon, Walmart, Inmobiliaria',
                        border: OutlineInputBorder(),
                        helperText: 'Donde se realizó la compra o servicio',
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged:
                          (value) => context.read<ConceptFormBloc>().add(
                            ConceptFormUpdateStoreEvent(value),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La tienda es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Monto total
                    TextFormField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Monto Total *',
                        hintText: 'Ej: 1500.00',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                        helperText: 'Cantidad total del gasto',
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
                          (value) => context.read<ConceptFormBloc>().add(
                            ConceptFormUpdateTotalEvent(value),
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

                    // Selector de tarjeta
                    BlocBuilder<CardBloc, CardState>(
                      builder: (context, cardState) {
                        if (cardState is LoadedCardState) {
                          if (cardState.cards.isEmpty) {
                            return const Card(
                              color: Colors.amber,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      'No hay tarjetas registradas',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Debe agregar al menos una tarjeta antes de continuar',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Seleccionar la primera tarjeta por defecto si no hay ninguna seleccionada
                          final FinancialCard? currentCard = state.selectedCard;

                          // Buscar la tarjeta seleccionada en la lista usando el ID
                          final FinancialCard selectedCard =
                              currentCard != null
                                  ? cardState.cards.firstWhere(
                                    (card) => card.id == currentCard.id,
                                    orElse: () => cardState.cards.first,
                                  )
                                  : cardState.cards.first;

                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Tarjeta *',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Tarjeta con la que se realizará el pago',
                            ),
                            value: selectedCard.id,
                            items:
                                cardState.cards.map((card) {
                                  String displayText =
                                      card.alias.isNotEmpty
                                          ? '${card.alias} - ${card.bankName}'
                                          : '${card.bankName} - ****${card.cardNumber.toString().substring(card.cardNumber.toString().length - 4)}';

                                  return DropdownMenuItem<String>(
                                    value: card.id,
                                    child: Text(displayText),
                                  );
                                }).toList(),
                            onChanged: (String? cardId) {
                              if (cardId != null) {
                                final selectedCard = cardState.cards.firstWhere(
                                  (card) => card.id == cardId,
                                );
                                context.read<ConceptFormBloc>().add(
                                  ConceptFormUpdateSelectedCardEvent(
                                    selectedCard,
                                  ),
                                );
                              }
                            },
                          );
                        }

                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    const SizedBox(height: 16),

                    // Modo de pago
                    DropdownButtonFormField<PaymentMode>(
                      decoration: const InputDecoration(
                        labelText: 'Modo de Pago *',
                        border: OutlineInputBorder(),
                        helperText:
                            'Frecuencia con la que se realizará el pago',
                      ),
                      value: state.paymentMode,
                      items:
                          PaymentMode.values.map((mode) {
                            String displayName;
                            switch (mode) {
                              case PaymentMode.oneTime:
                                displayName = 'Pago único';
                                break;
                              case PaymentMode.weekly:
                                displayName = 'Semanal';
                                break;
                              case PaymentMode.biweekly:
                                displayName = 'Quincenal';
                                break;
                              case PaymentMode.monthly:
                                displayName = 'Mensual';
                                break;
                            }

                            return DropdownMenuItem<PaymentMode>(
                              value: mode,
                              child: Text(displayName),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ConceptFormBloc>().add(
                            ConceptFormUpdatePaymentModeEvent(value),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de número de meses (solo si no es pago único)
                    if (showMonthsSelector) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Número de Meses: ${state.months}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: state.months.toDouble(),
                            min: 1,
                            max: 48,
                            divisions: 47,
                            label: state.months.toString(),
                            onChanged: (value) {
                              final intValue = value.round();
                              context.read<ConceptFormBloc>().add(
                                ConceptFormUpdateMonthsEvent(intValue),
                              );
                            },
                          ),
                          Text(
                            'Pagos en ${state.months} ${state.months == 1 ? 'mes' : 'meses'}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],

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
                          context.read<ConceptFormBloc>().add(
                            ConceptFormSaveEvent(
                              context: context,
                              isEditing: widget.isEditing,
                              conceptId: widget.conceptId,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.isEditing
                            ? 'Actualizar Concepto'
                            : 'Guardar Concepto',
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
