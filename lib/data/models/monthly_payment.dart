import 'package:economia/data/models/concept.dart';
import 'package:intl/intl.dart';

/// Representa un pago específico para un concepto en un mes determinado
class ConceptPayment {
  final Concept concept;
  final double amount;
  final int installmentNumber;
  final int totalInstallments;
  final DateTime paymentDate;

  ConceptPayment({
    required this.concept,
    required this.amount,
    required this.installmentNumber,
    required this.totalInstallments,
    required this.paymentDate,
  });

  String get formattedAmount {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    return currencyFormat.format(amount);
  }

  String get installmentText {
    if (totalInstallments <= 1) {
      return 'Pago único';
    }
    return 'Cuota $installmentNumber/$totalInstallments';
  }
}

/// Agrupa todos los pagos que corresponden a un mes específico
class MonthlyPayment {
  final DateTime month;
  final List<ConceptPayment> payments;

  MonthlyPayment({required this.month, required this.payments});

  double get totalAmount =>
      payments.fold(0, (sum, payment) => sum + payment.amount);

  String get formattedMonth {
    final monthName = DateFormat('MMMM yyyy', 'es_MX').format(month);
    return _capitalizeFirstLetter(monthName);
  }

  String get formattedTotalAmount {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );
    return currencyFormat.format(totalAmount);
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}
