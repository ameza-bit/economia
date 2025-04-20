import 'package:economia/data/blocs/recurring_payment_bloc.dart';
import 'package:economia/data/events/recurring_payment_event.dart';
import 'package:economia/data/repositories/recurring_payment_repository.dart';
import 'package:economia/ui/screens/recurring_payments/recurring_payment_form_screen.dart';
import 'package:economia/ui/views/recurring_payments/recurring_payment_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RecurringPaymentListScreen extends StatelessWidget {
  static const String routeName = 'recurring_payment_list';
  const RecurringPaymentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecurringPaymentBloc(
        repository: RecurringPaymentRepository(),
      )..add(LoadRecurringPaymentEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pagos Recurrentes'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar',
                onPressed: () => context.read<RecurringPaymentBloc>().add(
                  RefreshRecurringPaymentEvent()
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RecurringPaymentListView(),
        ),
        floatingActionButton: FloatingActionButton(
          key: const Key('add_recurring_payment'),
          heroTag: 'add_recurring_payment',
          child: const Icon(Icons.add_outlined),
          onPressed: () => context.goNamed(RecurringPaymentFormScreen.routeName),
        ),
      ),
    );
  }
}