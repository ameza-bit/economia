import 'dart:convert';

import 'package:economia/core/services/preferences.dart';
import 'package:economia/data/models/recurring_payment.dart';
import 'package:economia/data/services/recurring_payment_calculator.dart';

class RecurringPaymentRepository {
  final String _preferencesKey = 'recurring_payments';

  List<RecurringPayment> getRecurringPaymentsLocal() {
    try {
      String json = Preferences.getString(_preferencesKey);
      if (json.isNotEmpty) {
        List<dynamic> jsonList = jsonDecode(json);
        List<RecurringPayment> payments =
            jsonList.map((e) => RecurringPayment.fromJson(e)).toList();

        // Actualizar las próximas fechas de pago antes de devolver la lista
        payments = _updateNextPaymentDates(payments);
        saveRecurringPaymentsLocal(payments);

        return payments;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void saveRecurringPaymentsLocal(List<RecurringPayment> payments) {
    String json = jsonEncode(payments);
    Preferences.setString(_preferencesKey, json);
  }

  void deleteAllRecurringPaymentsLocal() {
    Preferences.setString(_preferencesKey, '');
  }

  void addRecurringPaymentLocal(RecurringPayment payment) {
    List<RecurringPayment> payments = getRecurringPaymentsLocal();
    payments.add(payment);
    saveRecurringPaymentsLocal(payments);
  }

  void deleteRecurringPaymentLocal(RecurringPayment payment) {
    List<RecurringPayment> payments = getRecurringPaymentsLocal();
    int index = payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      payments.removeAt(index);
      saveRecurringPaymentsLocal(payments);
    }
  }

  void updateRecurringPaymentLocal(RecurringPayment payment) {
    List<RecurringPayment> payments = getRecurringPaymentsLocal();
    int index = payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      payments[index] = payment;
      saveRecurringPaymentsLocal(payments);
    }
  }

  // Método para obtener los pagos recurrentes por año y mes
  List<RecurringPayment> getRecurringPaymentsByMonth(int year, int month) {
    List<RecurringPayment> allPayments = getRecurringPaymentsLocal();
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0); // Último día del mes

    return allPayments.where((payment) {
      // Verificar si el pago está activo
      if (!payment.isActive) return false;

      // Verificar si la fecha de inicio es anterior al fin del mes
      if (payment.startDate.isAfter(endDate)) return false;

      // Verificar si la fecha de fin (si existe) es posterior al inicio del mes
      if (payment.endDate != null && payment.endDate!.isBefore(startDate)) {
        return false;
      }

      // Calcular si hay alguna fecha de pago en este mes
      List<DateTime> paymentDates =
          RecurringPaymentCalculator.calculatePaymentDatesForPeriod(
            payment,
            startDate,
            endDate,
          );

      return paymentDates.isNotEmpty;
    }).toList();
  }

  // Método para actualizar las próximas fechas de pago
  List<RecurringPayment> _updateNextPaymentDates(
    List<RecurringPayment> payments,
  ) {
    final now = DateTime.now();

    return payments.map((payment) {
      // Si la próxima fecha de pago ya pasó, recalcularla
      if (payment.nextPaymentDate.isBefore(now)) {
        DateTime nextDate = RecurringPaymentCalculator.calculateNextPaymentDate(
          payment,
        );
        return payment.copyWith(nextPaymentDate: nextDate);
      }
      return payment;
    }).toList();
  }
}
