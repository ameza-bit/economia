import 'package:economia/data/blocs/concept_bloc.dart';
import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/events/concept_event.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/models/monthly_payment.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/states/recurring_payment_state.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/screens/recurring_payments/recurring_payment_form_screen.dart';
import 'package:economia/ui/screens/recurring_payments/recurring_payment_list_screen.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MonthlyPaymentCard extends StatelessWidget {
  final MonthlyPayment monthlyPayment;
  final bool isExpanded;
  final Function(bool) onToggleExpanded;

  const MonthlyPaymentCard({
    super.key,
    required this.monthlyPayment,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    // Separar pagos en "Pagados" y "Pendientes"
    final now = DateTime.now();
    final paidPayments =
        monthlyPayment.payments
            .where(
              (payment) =>
                  payment.paymentDate.isBefore(now) ||
                  payment.concept.manuallyMarkedAsPaid,
            )
            .toList();
    final pendingPayments =
        monthlyPayment.payments
            .where(
              (payment) =>
                  !payment.paymentDate.isBefore(now) &&
                  !payment.concept.manuallyMarkedAsPaid,
            )
            .toList();

    // Calcular montos totales por categoría
    final paidAmount = paidPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final pendingAmount = pendingPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con mes y monto total
          GestureDetector(
            onTap: () => onToggleExpanded(!isExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthlyPayment.formattedMonth,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      monthlyPayment.formattedTotalAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de pagos para este mes (solo si está expandido)
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),

            // Sección de pagos pendientes
            if (pendingPayments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    _formatAmount(pendingAmount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...pendingPayments.map(
                (payment) => _buildPaymentItem(context, payment),
              ),
            ],

            // Sección de pagos realizados
            if (paidPayments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pagados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    _formatAmount(paidAmount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...paidPayments.map(
                (payment) => _buildPaymentItem(context, payment, isPaid: true),
              ),
            ],

            // Mostrar mensaje si no hay pagos para este mes
            if (pendingPayments.isEmpty && paidPayments.isEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No hay pagos programados para este mes',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // Widget para cada elemento de pago
  Widget _buildPaymentItem(
    BuildContext context,
    ConceptPayment payment, {
    bool isPaid = false,
  }) {
    // Formatear la fecha de pago
    final paymentDateFormatted =
        '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}';

    // Detectar si es un pago recurrente (ID negativo)
    final bool isRecurringPayment = payment.concept.id < 0;

    // Variables para estados de pago
    bool isManuallyMarked = false;
    bool isAutomaticallyPaid = payment.paymentDate.isBefore(DateTime.now());

    // Si es un pago recurrente, buscar el objeto RecurringPayment original
    RecurringPayment? originalRecurringPayment;
    if (isRecurringPayment) {
      // Obtener el ID del pago recurrente (convertir de negativo a positivo)
      final String recurringPaymentId = payment.concept.id.abs().toString();

      // Obtener el bloc de pagos recurrentes
      final recurringPaymentBloc = context.read<RecurringPaymentBloc>();

      // Intentar encontrar el pago recurrente original
      if (recurringPaymentBloc.state is LoadedRecurringPaymentState) {
        final state = recurringPaymentBloc.state as LoadedRecurringPaymentState;
        originalRecurringPayment =
            state.payments.where((p) => p.id == recurringPaymentId).firstOrNull;
      }

      // Verificar si la fecha está marcada manualmente como pagada
      if (originalRecurringPayment != null) {
        isManuallyMarked = originalRecurringPayment.isDateMarkedAsPaid(
          payment.paymentDate,
        );
        isPaid = isManuallyMarked || isAutomaticallyPaid;
      }
    } else {
      // Para conceptos regulares
      isManuallyMarked = payment.concept.manuallyMarkedAsPaid;
      isPaid = isManuallyMarked || isAutomaticallyPaid;
    }

    return GestureDetector(
      onTap:
          () =>
              isRecurringPayment
                  ? _showRecurringPaymentOptions(
                    context,
                    payment,
                    originalRecurringPayment,
                  )
                  : _showPaymentOptions(context, payment),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Ícono de estado (pagado/pendiente/recurrente)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        isRecurringPayment
                            ? Icons.repeat
                            : (isPaid ? Icons.check_circle : Icons.schedule),
                        size: 16,
                        color:
                            isRecurringPayment
                                ? (isManuallyMarked
                                    ? Colors.green.shade700
                                    : Colors.purple)
                                : (isPaid
                                    ? Colors.green.shade700
                                    : Colors.orange),
                      ),
                      if (isManuallyMarked)
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Adelantado',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                payment.concept.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  // Texto tachado si está pagado
                                  decoration:
                                      isPaid
                                          ? TextDecoration.lineThrough
                                          : null,
                                  color: isPaid ? Colors.grey.shade600 : null,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Etiqueta para pagos recurrentes
                            if (isRecurringPayment)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Recurrente',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          isRecurringPayment
                              ? payment
                                  .concept
                                  .store // Proveedor para pagos recurrentes
                              : payment.concept.store,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isRecurringPayment
                                  ? 'Pago periódico' // Texto para pagos recurrentes
                                  : payment.installmentText,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isRecurringPayment
                                        ? Colors.purple.shade700
                                        : Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Fecha de pago
                            Text(
                              'Fecha de pago: $paymentDateFormatted',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    isPaid
                                        ? Colors.green.shade700
                                        : (isRecurringPayment
                                            ? Colors.purple.shade700
                                            : Colors.orange),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              payment.formattedAmount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPaid ? Colors.grey.shade600 : null,
                decoration: isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToConceptDetail(BuildContext context, dynamic concept) {
    // Detectar si es un pago recurrente (ID negativo)
    if (concept.id < 0) {
      // Convertir el ID negativo a un ID de pago recurrente (string)
      String recurringPaymentId = concept.id.abs().toString();

      // Obtener el bloc de pagos recurrentes
      final recurringPaymentBloc = context.read<RecurringPaymentBloc>();

      // Obtener el estado actual del bloc
      final state = recurringPaymentBloc.state;

      if (state is LoadedRecurringPaymentState) {
        // Buscar el pago recurrente por ID
        final RecurringPayment? payment =
            state.payments.where((p) => p.id == recurringPaymentId).firstOrNull;

        if (payment != null) {
          // Navegar a la pantalla de edición del pago recurrente
          context.goNamed(
            RecurringPaymentFormScreen.routeName,
            extra: {'payment': payment, 'isEditing': true},
          );
        } else {
          // Si no se encuentra el pago, navegar a la lista de pagos recurrentes
          context.goNamed(RecurringPaymentListScreen.routeName);

          // Opcionalmente, mostrar un mensaje
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'El pago recurrente no está disponible o ha sido eliminado',
              ),
            ),
          );
        }
      } else {
        // Si el estado no está cargado, navegar a la lista de pagos recurrentes
        context.goNamed(RecurringPaymentListScreen.routeName);
      }
    } else {
      // Para conceptos normales, usar la navegación existente
      context.goNamed(
        ConceptFormScreen.routeName,
        extra: {'concept': concept, 'isEditing': true},
      );
    }
  }

  void _showPaymentOptions(BuildContext context, ConceptPayment payment) {
    final bool isPaid =
        payment.concept.manuallyMarkedAsPaid ||
        payment.paymentDate.isBefore(DateTime.now());

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Ver detalle'),
                  onTap: () {
                    Navigator.pop(context);
                    _goToConceptDetail(context, payment.concept);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isPaid ? Icons.unpublished : Icons.check_circle_outline,
                    color: isPaid ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    isPaid ? 'Marcar como no pagado' : 'Marcar como pagado',
                    style: TextStyle(
                      color: isPaid ? Colors.orange : Colors.green,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Llamar al bloc para cambiar el estado
                    context.read<ConceptBloc>().add(
                      ToggleConceptPaidStatusEvent(
                        concept: payment.concept,
                        isPaid: !isPaid,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showRecurringPaymentOptions(
    BuildContext context,
    ConceptPayment payment,
    RecurringPayment? originalPayment,
  ) {
    if (originalPayment == null) {
      // Si no podemos encontrar el pago recurrente original, mostrar opciones limitadas
      showModalBottomSheet(
        context: context,
        builder:
            (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Ver detalle'),
                  onTap: () {
                    Navigator.pop(context);
                    _goToConceptDetail(context, payment.concept);
                  },
                ),
              ],
            ),
      );
      return;
    }

    // Verificar si la fecha está marcada como pagada
    final bool isMarkedPaid = originalPayment.isDateMarkedAsPaid(
      payment.paymentDate,
    );
    final bool isAutomaticallyPaid = payment.paymentDate.isBefore(
      DateTime.now(),
    );
    final bool isEffectivelyPaid = isMarkedPaid || isAutomaticallyPaid;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.visibility),
                  title: Text('Ver detalle'),
                  onTap: () {
                    Navigator.pop(context);
                    _goToConceptDetail(context, payment.concept);
                  },
                ),
                ListTile(
                  leading: Icon(
                    isEffectivelyPaid
                        ? Icons.unpublished
                        : Icons.check_circle_outline,
                    color: isEffectivelyPaid ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    isMarkedPaid
                        ? 'Desmarcar como pagado'
                        : (isAutomaticallyPaid
                            ? 'Confirmar como pagado'
                            : 'Marcar como pagado'),
                    style: TextStyle(
                      color: isEffectivelyPaid ? Colors.orange : Colors.green,
                    ),
                  ),
                  subtitle: Text(
                    isMarkedPaid
                        ? 'Pago marcado manualmente'
                        : (isAutomaticallyPaid
                            ? 'Pago considerado automáticamente'
                            : 'Pendiente de pago'),
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Llamar al bloc para cambiar el estado
                    context.read<RecurringPaymentBloc>().add(
                      ToggleRecurringPaymentDatePaidStatusEvent(
                        originalPayment.id,
                        payment.paymentDate,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Método auxiliar para formatear montos
  String _formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
