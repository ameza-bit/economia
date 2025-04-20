import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/models/monthly_payment.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/services/payment_calculator.dart';
import 'package:economia/data/services/recurring_payment_calculator.dart';
import 'package:economia/data/states/concept_state.dart';
import 'package:economia/data/states/recurring_payment_state.dart';
import 'package:economia/ui/widgets/concepts/concept_card.dart';
import 'package:economia/ui/widgets/concepts/monthly_payment_card.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
import 'package:economia/ui/widgets/recurring_payments/recurring_payment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConceptListView extends StatefulWidget {
  const ConceptListView({super.key});

  @override
  State<ConceptListView> createState() => _ConceptListViewState();
}

class _ConceptListViewState extends State<ConceptListView> {
  bool _showByMonth = true;
  final Set<int> _expandedIndices = {0}; // Por defecto, expandir el primer mes

  @override
  Widget build(BuildContext context) {
    // Obtener el bloc de pagos recurrentes al inicio
    final recurringPaymentBloc = context.read<RecurringPaymentBloc>();

    // Asegurar que tenemos los datos más recientes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        recurringPaymentBloc.add(RefreshRecurringPaymentEvent());
      }
    });

    return BlocBuilder<ConceptBloc, ConceptState>(
      builder: (BuildContext context, ConceptState conceptState) {
        return BlocBuilder<RecurringPaymentBloc, RecurringPaymentState>(
          builder: (context, recurringPaymentState) {
            // Manejar estados de carga e inicialización
            if (conceptState is InitialConceptState) {
              return const Center(child: Text('Iniciando...'));
            }
            if (conceptState is LoadingConceptState) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando Conceptos...'),
                  ],
                ),
              );
            }
            if (conceptState is ErrorConceptState) {
              return EmptyState(
                subtitle: conceptState.message,
                onRetry:
                    () =>
                        context.read<ConceptBloc>().add(RefreshConceptEvent()),
              );
            }

            // Extraer conceptos y pagos recurrentes
            final concepts = (conceptState as LoadedConceptState).concepts;
            List<RecurringPayment> recurringPayments = [];

            if (recurringPaymentState is LoadedRecurringPaymentState) {
              recurringPayments = recurringPaymentState.payments;
            }

            // Verificar si hay datos disponibles
            final bool hasData =
                concepts.isNotEmpty || recurringPayments.isNotEmpty;

            if (!hasData) {
              return EmptyState(
                subtitle: 'No hay conceptos ni pagos recurrentes disponibles',
                onRetry: () {
                  context.read<ConceptBloc>().add(RefreshConceptEvent());
                  context.read<RecurringPaymentBloc>().add(
                    RefreshRecurringPaymentEvent(),
                  );
                },
              );
            }

            return Column(
              children: [
                // Selector de vista
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Si el ancho es menor a 400px, usamos un layout vertical
                        if (constraints.maxWidth < 400) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo de visualización:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: true,
                                    label: Text('Por Mes'),
                                    icon: Icon(Icons.calendar_month),
                                  ),
                                  ButtonSegment(
                                    value: false,
                                    label: Text('Individual'),
                                    icon: Icon(Icons.receipt_long),
                                  ),
                                ],
                                selected: {_showByMonth},
                                onSelectionChanged: (Set<bool> newSelection) {
                                  setState(() {
                                    _showByMonth = newSelection.first;
                                  });
                                },
                              ),
                            ],
                          );
                        } else {
                          // En pantallas más anchas, usamos el layout horizontal original
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Modo de visualización:',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: true,
                                    label: Text('Por Mes'),
                                    icon: Icon(Icons.calendar_month),
                                  ),
                                  ButtonSegment(
                                    value: false,
                                    label: Text('Individual'),
                                    icon: Icon(Icons.receipt_long),
                                  ),
                                ],
                                selected: {_showByMonth},
                                onSelectionChanged: (Set<bool> newSelection) {
                                  setState(() {
                                    _showByMonth = newSelection.first;
                                  });
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),

                // Contenido principal
                Expanded(
                  child:
                      _showByMonth
                          ? _buildMonthlyView(concepts, recurringPayments)
                          : _buildIndividualView(concepts, recurringPayments),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método modificado para construir la vista mensual incluyendo pagos recurrentes
  Widget _buildMonthlyView(
    List<Concept> concepts,
    List<RecurringPayment> recurringPayments,
  ) {
    // Agrupar conceptos por mes de pago
    List<MonthlyPayment> monthlyPayments =
        PaymentCalculator.groupConceptsByPaymentMonth(concepts);

    // Añadir pagos recurrentes a los pagos mensuales
    monthlyPayments = _addRecurringPaymentsToMonthly(
      monthlyPayments,
      recurringPayments,
    );

    if (monthlyPayments.isEmpty) {
      return const Center(child: Text('No hay pagos próximos'));
    }

    return ListView.builder(
      itemCount: monthlyPayments.length,
      itemBuilder: (context, index) {
        bool isExpanded = _expandedIndices.contains(index);

        return MonthlyPaymentCard(
          monthlyPayment: monthlyPayments[index],
          isExpanded: isExpanded,
          onToggleExpanded: (expanded) {
            setState(() {
              if (expanded) {
                _expandedIndices.add(index);
              } else {
                _expandedIndices.remove(index);
              }
            });
          },
        );
      },
    );
  }

  // Método modificado para la vista individual
  Widget _buildIndividualView(
    List<Concept> concepts,
    List<RecurringPayment> recurringPayments,
  ) {
    return ListView(
      children: [
        // Sección de conceptos
        if (concepts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Conceptos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...concepts.map((concept) => ConceptCard(concept: concept)),
        ],

        // Sección de pagos recurrentes
        if (recurringPayments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Pagos Recurrentes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...recurringPayments.map(
            (payment) => RecurringPaymentItem(payment: payment),
          ),
        ],
      ],
    );
  }

  // Método nuevo para convertir pagos recurrentes en ConceptPayment
  List<MonthlyPayment> _addRecurringPaymentsToMonthly(
    List<MonthlyPayment> monthlyPayments,
    List<RecurringPayment> recurringPayments,
  ) {
    // Crear un mapa para acceder más fácilmente a los pagos por mes
    Map<String, MonthlyPayment> paymentsByMonthKey = {};
    for (var payment in monthlyPayments) {
      String key =
          "${payment.month.year}-${payment.month.month.toString().padLeft(2, '0')}";
      paymentsByMonthKey[key] = payment;
    }

    // Obtener fecha actual
    final now = DateTime.now();

    // Proyectar pagos recurrentes para los próximos 6 meses
    final endDate = DateTime(now.year, now.month + 6, 1);

    // Procesar cada pago recurrente
    for (var recurringPayment in recurringPayments) {
      // Solo considerar pagos activos
      if (!recurringPayment.isActive) continue;

      // Obtener las fechas de pago para los próximos meses
      List<DateTime> paymentDates = [];

      // Si la fecha de inicio es futura, usar esa como punto de partida
      DateTime startDate =
          recurringPayment.startDate.isAfter(now)
              ? recurringPayment.startDate
              : now;

      // Calcular fechas de pago
      paymentDates = RecurringPaymentCalculator.calculatePaymentDatesForPeriod(
        recurringPayment,
        startDate,
        endDate,
      );

      // Agregar cada fecha de pago al mes correspondiente
      for (var paymentDate in paymentDates) {
        // Crear un ConceptPayment "sintético" para el pago recurrente
        ConceptPayment conceptPayment = _createConceptPaymentFromRecurring(
          recurringPayment,
          paymentDate,
        );

        // Obtener la clave del mes
        String monthKey =
            "${paymentDate.year}-${paymentDate.month.toString().padLeft(2, '0')}";

        // Obtener o crear el MonthlyPayment para este mes
        if (!paymentsByMonthKey.containsKey(monthKey)) {
          paymentsByMonthKey[monthKey] = MonthlyPayment(
            month: DateTime(paymentDate.year, paymentDate.month, 1),
            payments: [],
          );
        }

        // Añadir el pago al mes correspondiente
        paymentsByMonthKey[monthKey]!.payments.add(conceptPayment);
      }
    }

    // Convertir el mapa de nuevo a lista
    List<MonthlyPayment> result = paymentsByMonthKey.values.toList();

    // Ordenar por fecha
    result.sort((a, b) => a.month.compareTo(b.month));

    return result;
  }

  // Método para crear un ConceptPayment a partir de un pago recurrente
  ConceptPayment _createConceptPaymentFromRecurring(
    RecurringPayment recurringPayment,
    DateTime paymentDate,
  ) {
    // Crear un concepto "sintético" para representar el pago recurrente
    Concept syntheticConcept = Concept(
      id: -int.parse(recurringPayment.id), // ID negativo para distinguirlo
      name: recurringPayment.name,
      description: recurringPayment.description,
      store: recurringPayment.provider,
      total: recurringPayment.amount,
      card: recurringPayment.card ?? _createDefaultCard(),
      purchaseDate: recurringPayment.startDate,
    );

    return ConceptPayment(
      concept: syntheticConcept,
      amount: recurringPayment.amount,
      installmentNumber: 1,
      totalInstallments:
          1, // Para pagos recurrentes, cada pago es independiente
      paymentDate: paymentDate,
    );
  }

  // Método para crear una tarjeta por defecto para pagos sin tarjeta asignada
  FinancialCard _createDefaultCard() {
    return FinancialCard(
      id: "default",
      cardNumber: 0000,
      cardType: CardType.other,
      expirationDate: DateTime.now().add(const Duration(days: 365)),
      paymentDay: 1,
      cutOffDay: 1,
      bankName: "Efectivo",
      alias: "Efectivo/Sin tarjeta",
      cardholderName: "No asignado",
      cardNetwork: CardNetwork.other,
    );
  }
}
