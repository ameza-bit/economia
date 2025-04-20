import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/models/monthly_payment.dart';
import 'package:economia/data/services/payment_calculator.dart';
import 'package:economia/data/states/concept_state.dart';
import 'package:economia/ui/widgets/concepts/concept_card.dart';
import 'package:economia/ui/widgets/concepts/monthly_payment_card.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
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
    return BlocBuilder<ConceptBloc, ConceptState>(
      builder: (BuildContext context, ConceptState state) {
        switch (state) {
          case InitialConceptState():
            return const Center(child: Text('Iniciando...'));
          case LoadingConceptState():
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
          case ErrorConceptState():
            return EmptyState(
              subtitle: state.message,
              onRetry:
                  () => context.read<ConceptBloc>().add(RefreshConceptEvent()),
            );
          case LoadedConceptState():
            if (state.concepts.isEmpty) {
              return EmptyState(
                subtitle: 'No hay conceptos disponibles',
                onRetry:
                    () =>
                        context.read<ConceptBloc>().add(RefreshConceptEvent()),
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
                          ? _buildMonthlyView(state.concepts)
                          : _buildIndividualView(state.concepts),
                ),
              ],
            );
        }
      },
    );
  }

  Widget _buildMonthlyView(List<Concept> concepts) {
    // Agrupar conceptos por mes de pago
    List<MonthlyPayment> monthlyPayments =
        PaymentCalculator.groupConceptsByPaymentMonth(concepts);

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

  Widget _buildIndividualView(List<dynamic> concepts) {
    return ListView.builder(
      itemCount: concepts.length,
      itemBuilder: (context, index) => ConceptCard(concept: concepts[index]),
    );
  }
}
