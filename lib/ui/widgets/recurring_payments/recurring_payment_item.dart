// lib/ui/widgets/recurring_payments/recurring_payment_item.dart
import 'package:economia/data/blocs/recurring_payment_form_bloc.dart';
import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/events/recurring_payment_form_event.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/data/states/recurring_payment_form_state.dart';
import 'package:economia/ui/screens/recurring_payments/recurring_payment_form_screen.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecurringPaymentItem extends StatelessWidget {
  final RecurringPayment payment;

  const RecurringPaymentItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    final formattedAmount = currencyFormat.format(payment.amount);
    final nextPaymentFormatted = DateFormat(
      'dd/MM/yyyy',
      'es_MX',
    ).format(payment.nextPaymentDate);

    final bool isActive = payment.isActive;
    final bool isPastDue = payment.nextPaymentDate.isBefore(DateTime.now());

    String recurringDescription = payment.getPaymentDateDescription();
    if (payment.recurrenceType == RecurrenceType.biweekly &&
        payment.paymentDateType == PaymentDateType.specificDay &&
        payment.secondSpecificDay != null) {
      recurringDescription =
          'Días ${payment.specificDay} y ${payment.secondSpecificDay} de cada mes';
    }

    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      backgroundColor:
          isActive
              ? payment.recurrenceType.color.withAlpha(50)
              : Colors.grey.shade200,
      shadow: true,
      onLongPress: () => _showOptions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isActive
                          ? (isPastDue
                              ? Icons.warning
                              : Icons.check_circle_outline)
                          : Icons.cancel_outlined,
                      color:
                          isActive
                              ? (isPastDue ? Colors.orange : Colors.green)
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isActive
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editPayment(context);
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  } else if (value == 'toggle') {
                    _toggleActive(context);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_outline,
                              size: 20,
                              color: isActive ? Colors.red : Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              isActive ? 'Desactivar' : 'Activar',
                              style: TextStyle(
                                color: isActive ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Información de proveedor
          Row(
            children: [
              Icon(
                Icons.store_outlined,
                color: isActive ? Colors.blue.shade700 : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  payment.provider,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.black87 : Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          if (payment.category.isNotEmpty && payment.category != 'General') ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  color: isActive ? Colors.blue.shade700 : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  payment.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isActive ? Colors.black54 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],

          if (payment.card != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.credit_card_outlined,
                  color: isActive ? Colors.blue.shade700 : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    payment.card!.alias.isNotEmpty
                        ? '${payment.card!.alias} - ${payment.card!.bankName}'
                        : '${payment.card!.bankName} - ****${payment.card!.cardNumber.toString().substring(payment.card!.cardNumber.toString().length - 4)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isActive ? Colors.black54 : Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Detalles de recurrencia
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.repeat,
                          size: 18,
                          color: isActive ? Colors.indigo : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.recurrenceType.displayName,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isActive ? Colors.indigo : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        recurringDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: isActive ? Colors.black54 : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? (isPastDue
                              ? Colors.orange.shade100
                              : Colors.green.shade100)
                          : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isActive
                                ? (isPastDue
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800)
                                : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Próximo: $nextPaymentFormatted',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            isActive
                                ? (isPastDue
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800)
                                : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Descripción (si existe)
          if (payment.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: isActive ? Colors.grey.shade700 : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    payment.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color:
                          isActive
                              ? Colors.grey.shade700
                              : Colors.grey.shade500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Método para mostrar opciones en modal
  void _showOptions(BuildContext context) {
    final bool isActive = payment.isActive;

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar pago recurrente'),
                onTap: () {
                  Navigator.pop(context);
                  _editPayment(context);
                },
              ),
              ListTile(
                leading: Icon(
                  isActive ? Icons.cancel_outlined : Icons.check_circle_outline,
                  color: isActive ? Colors.red : Colors.green,
                ),
                title: Text(
                  isActive ? 'Desactivar pago' : 'Activar pago',
                  style: TextStyle(color: isActive ? Colors.red : Colors.green),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleActive(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Eliminar pago recurrente',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
    );
  }

  // Método para editar pago recurrente
  void _editPayment(BuildContext context) {
    context.goNamed(
      RecurringPaymentFormScreen.routeName,
      extra: {'payment': payment, 'isEditing': true},
    );
  }

  // Método para activar/desactivar pago
  void _toggleActive(BuildContext context) {
    // Crear un bloc temporal para manejar la actualización
    final bloc = RecurringPaymentFormBloc(
      recurringPaymentRepository: RecurringPaymentRepository(),
      cardRepository: CardRepository(),
    );

    // Cargar el pago existente
    bloc.add(RecurringPaymentFormLoadExistingPaymentEvent(payment));

    // Esperar a que se cargue y luego actualizar el estado
    Future.delayed(Duration(milliseconds: 100), () {
      if (bloc.state is RecurringPaymentFormReadyState) {
        // Actualizar estado y guardar
        bloc.add(RecurringPaymentFormUpdateIsActiveEvent(!payment.isActive));
        if (context.mounted) {
          bloc.add(
            RecurringPaymentFormSaveEvent(
              context: context,
              isEditing: true,
              paymentId: payment.id,
            ),
          );
        }
      }
    });
  }

  // Método para confirmar y eliminar pago
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar Pago Recurrente'),
            content: Text(
              '¿Estás seguro de que deseas eliminar este pago recurrente?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // Crear un bloc temporal para manejar la eliminación
                  final bloc = RecurringPaymentFormBloc(
                    recurringPaymentRepository: RecurringPaymentRepository(),
                    cardRepository: CardRepository(),
                  );
                  bloc.add(
                    RecurringPaymentFormDeleteEvent(
                      paymentId: payment.id,
                      context: context,
                    ),
                  );
                },
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
