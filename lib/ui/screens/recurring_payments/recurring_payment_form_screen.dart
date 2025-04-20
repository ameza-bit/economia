import 'package:economia/data/blocs/recurring_payment_form_bloc.dart';
import 'package:economia/data/events/recurring_payment_form_event.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/ui/views/recurring_payments/recurring_payment_form_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringPaymentFormScreen extends StatelessWidget {
  static const String routeName = 'recurring_payment_form';

  const RecurringPaymentFormScreen({
    super.key,
    this.isEditing = false,
    this.payment,
  });

  final bool isEditing;
  final RecurringPayment? payment;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = RecurringPaymentFormBloc(
          recurringPaymentRepository: RecurringPaymentRepository(),
          cardRepository: CardRepository(),
        );

        // Si estamos en modo edición, cargar el pago existente
        if (isEditing && payment != null) {
          bloc.add(RecurringPaymentFormLoadExistingPaymentEvent(payment!));
        } else {
          bloc.add(RecurringPaymentFormInitEvent());
        }

        return bloc;
      },
      child: RecurringPaymentFormView(
        isEditing: isEditing,
        paymentId: payment?.id,
      ),
    );
  }
}
