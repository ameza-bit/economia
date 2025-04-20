import 'package:economia/data/models/monthly_payment.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
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
            .where((payment) => payment.paymentDate.isBefore(now))
            .toList();
    final pendingPayments =
        monthlyPayment.payments
            .where((payment) => !payment.paymentDate.isBefore(now))
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

    return GestureDetector(
      onTap: () => _goToConceptDetail(context, payment.concept),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Ícono de estado (pagado/pendiente)
                  Icon(
                    isPaid ? Icons.check_circle : Icons.schedule,
                    size: 16,
                    color: isPaid ? Colors.green.shade700 : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.concept.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            // Texto tachado si está pagado
                            decoration:
                                isPaid ? TextDecoration.lineThrough : null,
                            color: isPaid ? Colors.grey.shade600 : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          payment.concept.store,
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
                              payment.installmentText,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
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
                                        : Colors.orange,
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
    context.goNamed(
      ConceptFormScreen.routeName,
      extra: {'concept': concept, 'isEditing': true},
    );
  }

  // Método auxiliar para formatear montos
  String _formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
