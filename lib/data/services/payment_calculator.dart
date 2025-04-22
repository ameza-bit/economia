import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/models/monthly_payment.dart';

class PaymentCalculator {
  /// Agrupa los conceptos por mes de pago
  static List<MonthlyPayment> groupConceptsByPaymentMonth(
    List<Concept> concepts,
  ) {
    // Mapa para agrupar pagos por mes (clave: año-mes)
    Map<String, List<ConceptPayment>> paymentsByMonth = {};

    for (var concept in concepts) {
      List<ConceptPayment> payments = calculatePaymentsForConcept(concept);

      for (var payment in payments) {
        String monthKey =
            '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}';

        if (!paymentsByMonth.containsKey(monthKey)) {
          paymentsByMonth[monthKey] = [];
        }

        paymentsByMonth[monthKey]!.add(payment);
      }
    }

    // Convertir el mapa a una lista de MonthlyPayment
    List<MonthlyPayment> monthlyPayments = [];

    paymentsByMonth.forEach((key, payments) {
      int year = int.parse(key.split('-')[0]);
      int month = int.parse(key.split('-')[1]);

      monthlyPayments.add(
        MonthlyPayment(month: DateTime(year, month, 1), payments: payments),
      );
    });

    // Ordenar los pagos mensuales por fecha
    monthlyPayments.sort((a, b) => a.month.compareTo(b.month));

    return monthlyPayments;
  }

  /// Calcula los pagos individuales para un concepto
  static List<ConceptPayment> calculatePaymentsForConcept(Concept concept) {
    List<ConceptPayment> payments = [];

    if (concept.paymentMode == PaymentMode.oneTime) {
      // Para pagos únicos, solo hay un pago
      DateTime paymentDate = calculatePaymentDate(concept, 0);

      payments.add(
        ConceptPayment(
          concept: concept,
          amount: concept.total,
          installmentNumber: 1,
          totalInstallments: 1,
          paymentDate: paymentDate,
        ),
      );
    } else {
      // Para pagos a plazos, dividir el monto en cuotas
      double monthlyAmount = concept.total / concept.months;

      for (int i = 0; i < concept.months; i++) {
        DateTime paymentDate = calculatePaymentDate(concept, i);

        payments.add(
          ConceptPayment(
            concept: concept,
            amount: monthlyAmount,
            installmentNumber: i + 1,
            totalInstallments: concept.months,
            paymentDate: paymentDate,
          ),
        );
      }
    }

    return payments;
  }

  /// Calcula la fecha de pago para una cuota específica
  static DateTime calculatePaymentDate(Concept concept, int installmentNumber) {
    // Fecha de compra
    final purchaseDate = concept.purchaseDate;

    // Fecha de corte del mes de la compra
    DateTime cutOffDate = DateTime(
      purchaseDate.year,
      purchaseDate.month,
      concept.card.cutOffDay,
    );

    // Ajustar si el día de corte es mayor que los días del mes
    if (concept.card.cutOffDay >
        daysInMonth(purchaseDate.year, purchaseDate.month)) {
      cutOffDate = DateTime(
        purchaseDate.year,
        purchaseDate.month + 1,
        0,
      ); // Último día del mes
    }

    // Determinar si la compra ya pasó el corte
    bool passedCutoff = purchaseDate.isAfter(cutOffDate);

    // El primer pago depende de si ya pasó la fecha de corte
    DateTime firstPaymentDate;
    if (passedCutoff) {
      // Si ya pasó el corte, el primer pago será el mes siguiente
      firstPaymentDate = DateTime(
        purchaseDate.year,
        purchaseDate.month + 1,
        concept.card.paymentDay,
      );
    } else {
      // Si no ha pasado el corte, el primer pago será este mes
      firstPaymentDate = DateTime(
        purchaseDate.year,
        purchaseDate.month,
        concept.card.paymentDay,
      );
    }

    // Calcular la fecha para la cuota específica
    DateTime paymentDate = DateTime(
      firstPaymentDate.year,
      firstPaymentDate.month + installmentNumber,
      concept.card.paymentDay,
    );

    // Normalizar la fecha si el mes es mayor a 12
    if (paymentDate.month > 12) {
      paymentDate = DateTime(
        paymentDate.year + ((paymentDate.month - 1) ~/ 12),
        ((paymentDate.month - 1) % 12) + 1,
        paymentDate.day,
      );
    }

    // Ajustar si el día de pago es mayor que los días del mes
    if (concept.card.paymentDay >
        daysInMonth(paymentDate.year, paymentDate.month)) {
      paymentDate = DateTime(
        paymentDate.year,
        paymentDate.month + 1,
        0,
      ); // Último día del mes
    }

    return paymentDate;
  }

  /// Calcula el número de días en un mes específico
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Calcula cuántas cuotas se han pagado de un concepto hasta la fecha actual
  static int getPaidInstallments(Concept concept) {
    if (concept.paymentMode == PaymentMode.oneTime) {
      // Para pagos únicos, o está pagado (1) o no (0)
      DateTime paymentDate = calculatePaymentDate(concept, 0);
      return DateTime.now().isAfter(paymentDate) ? 1 : 0;
    } else {
      // Para pagos a plazos, contar cuántas cuotas ya pasaron su fecha de vencimiento
      List<ConceptPayment> payments = calculatePaymentsForConcept(concept);
      int paidCount = 0;
      final now = DateTime.now();

      for (var payment in payments) {
        if (now.isAfter(payment.paymentDate)) {
          paidCount++;
        }
      }

      return paidCount;
    }
  }

  /// Calcula el total pagado de un concepto hasta la fecha actual
  static bool isPaymentPaid(ConceptPayment payment) {
    // Un pago está "pagado" si:
    // - Está manualmente marcado como pagado, o
    // - Su fecha de pago ya pasó (automáticamente)
    return payment.concept.manuallyMarkedAsPaid ||
        payment.paymentDate.isBefore(DateTime.now());
  }
}
