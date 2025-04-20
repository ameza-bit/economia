import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/states/recurring_payment_state.dart';
import 'package:economia/ui/widgets/general/empty_state.dart';
import 'package:economia/ui/widgets/recurring_payments/recurring_payment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecurringPaymentListView extends StatefulWidget {
  const RecurringPaymentListView({super.key});

  @override
  State<RecurringPaymentListView> createState() =>
      _RecurringPaymentListViewState();
}

class _RecurringPaymentListViewState extends State<RecurringPaymentListView> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringPaymentBloc, RecurringPaymentState>(
      builder: (context, state) {
        switch (state) {
          case InitialRecurringPaymentState():
            return const Center(child: Text('Iniciando...'));

          case LoadingRecurringPaymentState():
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando Pagos Recurrentes...'),
                ],
              ),
            );

          case ErrorRecurringPaymentState():
            return EmptyState(
              title: 'Error',
              subtitle: state.message,
              onRetry:
                  () => context.read<RecurringPaymentBloc>().add(
                    RefreshRecurringPaymentEvent(),
                  ),
            );

          case LoadedRecurringPaymentState():
            return Column(
              children: [
                // Selector de mes/año
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtrar por fecha',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Selector de mes
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Mes',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                value: _selectedMonth,
                                items: List.generate(12, (index) {
                                  final month = index + 1;
                                  return DropdownMenuItem<int>(
                                    value: month,
                                    child: Text(
                                      DateFormat(
                                        'MMMM',
                                        'es_MX',
                                      ).format(DateTime(2021, month)),
                                    ),
                                  );
                                }),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedMonth = value;
                                    });
                                    context.read<RecurringPaymentBloc>().add(
                                      FilterRecurringPaymentByMonthEvent(
                                        _selectedYear,
                                        _selectedMonth,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Selector de año
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Año',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                value: _selectedYear,
                                items: List.generate(5, (index) {
                                  final year = DateTime.now().year - 1 + index;
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedYear = value;
                                    });
                                    context.read<RecurringPaymentBloc>().add(
                                      FilterRecurringPaymentByMonthEvent(
                                        _selectedYear,
                                        _selectedMonth,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Mostrar Todos'),
                              onPressed: () {
                                context.read<RecurringPaymentBloc>().add(
                                  RefreshRecurringPaymentEvent(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de pagos recurrentes
                Expanded(
                  child:
                      state.payments.isEmpty
                          ? EmptyState(
                            title: 'Sin Pagos Recurrentes',
                            subtitle:
                                'No hay pagos recurrentes registrados o que coincidan con el filtro',
                            onRetry:
                                () => context.read<RecurringPaymentBloc>().add(
                                  RefreshRecurringPaymentEvent(),
                                ),
                          )
                          : _buildRecurringPaymentsList(state.payments),
                ),
              ],
            );
        }
      },
    );
  }

  Widget _buildRecurringPaymentsList(List<RecurringPayment> payments) {
    // Ordenar por próxima fecha de pago
    payments.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

    // Separar en activos e inactivos
    final activePayments = payments.where((p) => p.isActive).toList();
    final inactivePayments = payments.where((p) => !p.isActive).toList();

    return ListView(
      children: [
        if (activePayments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Pagos Activos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...activePayments.map(
            (payment) => RecurringPaymentItem(payment: payment),
          ),
        ],

        if (inactivePayments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.grey, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Pagos Inactivos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          ...inactivePayments.map(
            (payment) => RecurringPaymentItem(payment: payment),
          ),
        ],
      ],
    );
  }
}
