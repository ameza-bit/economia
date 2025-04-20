import 'package:economia/data/enums/payment_date_type.dart';
import 'package:economia/data/enums/recurrence_type.dart';
import 'package:economia/data/enums/week_day.dart';
import 'package:economia/data/models/recurring_payment.dart';

class RecurringPaymentCalculator {
  // Calcula la próxima fecha de pago a partir de la fecha actual
  static DateTime calculateNextPaymentDate(
    RecurringPayment payment, [
    DateTime? fromDate,
  ]) {
    final DateTime baseDate = fromDate ?? DateTime.now();
    DateTime nextDate;

    switch (payment.paymentDateType) {
      case PaymentDateType.specificDay:
        nextDate = _calculateNextSpecificDay(payment, baseDate);
        break;
      case PaymentDateType.weekDay:
        nextDate = _calculateNextWeekDay(payment, baseDate);
        break;
      case PaymentDateType.lastDayOfMonth:
        nextDate = _calculateNextLastDayOfMonth(payment, baseDate);
        break;
    }

    // Si hay una fecha de finalización y la próxima fecha es posterior, retornar null
    if (payment.endDate != null && nextDate.isAfter(payment.endDate!)) {
      return payment.endDate!;
    }

    return nextDate;
  }

  // Calcula las próximas N fechas de pago
  static List<DateTime> calculateNextNPaymentDates(
    RecurringPayment payment,
    int count, [
    DateTime? fromDate,
  ]) {
    List<DateTime> dates = [];
    DateTime currentDate = fromDate ?? DateTime.now();

    for (int i = 0; i < count; i++) {
      DateTime nextDate = calculateNextPaymentDate(payment, currentDate);

      // Si llegamos a la fecha de finalización, salimos del bucle
      if (payment.endDate != null && nextDate.isAfter(payment.endDate!)) {
        if (!dates.contains(payment.endDate!)) {
          dates.add(payment.endDate!);
        }
        break;
      }

      dates.add(nextDate);
      // Avanzamos un día después de la fecha calculada para encontrar la siguiente
      currentDate = nextDate.add(const Duration(days: 1));
    }

    return dates;
  }

  // Calcula las fechas de pago para un período específico
  static List<DateTime> calculatePaymentDatesForPeriod(
    RecurringPayment payment,
    DateTime startDate,
    DateTime endDate,
  ) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;

    // Caso especial para pagos quincenales con dos días específicos
    if (payment.recurrenceType == RecurrenceType.biweekly &&
        payment.paymentDateType == PaymentDateType.specificDay &&
        payment.secondSpecificDay != null) {
      while (currentDate.isBefore(endDate)) {
        // Obtener el año y mes actuales
        int year = currentDate.year;
        int month = currentDate.month;
        int daysInMonth = _daysInMonth(year, month);

        // Primer día de pago en el mes
        int firstDay =
            payment.specificDay > daysInMonth
                ? daysInMonth
                : payment.specificDay;
        DateTime firstPayment = DateTime(year, month, firstDay);

        // Segundo día de pago en el mes
        int secondDay =
            payment.secondSpecificDay! > daysInMonth
                ? daysInMonth
                : payment.secondSpecificDay!;
        DateTime secondPayment = DateTime(year, month, secondDay);

        // Añadir primer día si está dentro del rango
        if (firstPayment.isAfter(currentDate) &&
            firstPayment.isBefore(endDate)) {
          dates.add(firstPayment);
        }

        // Añadir segundo día si está dentro del rango
        if (secondPayment.isAfter(currentDate) &&
            secondPayment.isBefore(endDate)) {
          dates.add(secondPayment);
        }

        // Avanzar al siguiente mes
        currentDate = DateTime(year, month + 1, 1);
      }

      return dates;
    }

    // Código existente para otros casos...
    while (currentDate.isBefore(endDate)) {
      DateTime nextDate = calculateNextPaymentDate(payment, currentDate);

      if (nextDate.isAfter(endDate)) {
        break;
      }

      dates.add(nextDate);
      // Avanzamos un día después de la fecha calculada para encontrar la siguiente
      currentDate = nextDate.add(const Duration(days: 1));

      // Si llegamos a la fecha de finalización, salimos del bucle
      if (payment.endDate != null && nextDate.isAfter(payment.endDate!)) {
        break;
      }
    }

    return dates;
  }

  // Calcula la próxima fecha para un día específico del mes
  static DateTime _calculateNextSpecificDay(
    RecurringPayment payment,
    DateTime fromDate,
  ) {
    DateTime baseDate = DateTime(fromDate.year, fromDate.month, 1);
    int day = payment.specificDay;

    // Ajustar el día si excede el máximo del mes
    int daysInMonth = _daysInMonth(baseDate.year, baseDate.month);
    day = day > daysInMonth ? daysInMonth : day;

    DateTime targetDate = DateTime(baseDate.year, baseDate.month, day);

    // Manejo especial para pagos quincenales con dos días específicos
    if (payment.recurrenceType == RecurrenceType.biweekly &&
        payment.paymentDateType == PaymentDateType.specificDay &&
        payment.secondSpecificDay != null) {
      int secondDay = payment.secondSpecificDay!;
      secondDay = secondDay > daysInMonth ? daysInMonth : secondDay;
      DateTime secondTargetDate = DateTime(
        baseDate.year,
        baseDate.month,
        secondDay,
      );

      // Si estamos después del primer día pero antes del segundo, elegir el segundo día
      if (fromDate.isAfter(targetDate) && fromDate.isBefore(secondTargetDate)) {
        return secondTargetDate;
      }
      // Si estamos después de ambos días, ir al primer día del siguiente mes
      else if (fromDate.isAfter(targetDate) &&
          fromDate.isAfter(secondTargetDate)) {
        DateTime nextMonth = DateTime(baseDate.year, baseDate.month + 1, 1);
        return DateTime(nextMonth.year, nextMonth.month, day);
      }
      // De lo contrario, elegir el primer día
      else {
        return targetDate;
      }
    }

    // Código existente para otros casos...
    if (targetDate.isBefore(fromDate) ||
        targetDate.isAtSameMomentAs(fromDate)) {
      targetDate = _advanceByRecurrenceType(targetDate, payment.recurrenceType);

      daysInMonth = _daysInMonth(targetDate.year, targetDate.month);
      day =
          payment.specificDay > daysInMonth ? daysInMonth : payment.specificDay;

      targetDate = DateTime(targetDate.year, targetDate.month, day);
    }

    return targetDate;
  }

  // Calcula la próxima fecha para un día de la semana específico
  static DateTime _calculateNextWeekDay(
    RecurringPayment payment,
    DateTime fromDate,
  ) {
    if (payment.weekDay == null) {
      // Si no hay día de la semana definido, usar la fecha base
      return fromDate;
    }

    DateTime baseDate = DateTime(fromDate.year, fromDate.month, 1);
    WeekDay weekDay = payment.weekDay!;
    int ordinal = payment.weekDayOrdinal;

    // Calcular el primer día del mes que coincide con el día de la semana
    int firstDayOfWeek = weekDay.dayNumber;
    int firstDayOfMonth = baseDate.weekday;

    int daysToAdd = (firstDayOfWeek - firstDayOfMonth + 7) % 7;
    DateTime firstOccurrence = baseDate.add(Duration(days: daysToAdd));

    DateTime targetDate;

    // Manejar el caso especial de "último"
    if (ordinal == -1) {
      // Ir al primer día del siguiente mes y retroceder para encontrar el último del mes actual
      DateTime firstDayOfNextMonth = DateTime(
        baseDate.year,
        baseDate.month + 1,
        1,
      );
      DateTime lastDayOfMonth = firstDayOfNextMonth.subtract(
        const Duration(days: 1),
      );

      // Retroceder hasta encontrar el día de la semana
      int daysToSubtract = (lastDayOfMonth.weekday - firstDayOfWeek + 7) % 7;
      targetDate = lastDayOfMonth.subtract(Duration(days: daysToSubtract));
    } else {
      // Calcular la ocurrencia específica (1ª, 2ª, 3ª, 4ª)
      targetDate = firstOccurrence.add(Duration(days: (ordinal - 1) * 7));

      // Validar que la fecha no exceda el mes
      int daysInMonth = _daysInMonth(baseDate.year, baseDate.month);
      if (targetDate.day > daysInMonth) {
        // Si la ocurrencia no existe en este mes, tomar la última disponible
        targetDate = DateTime(baseDate.year, baseDate.month, daysInMonth);
      }
    }

    // Si la fecha objetivo ya pasó, avanzamos según la recurrencia
    if (targetDate.isBefore(fromDate) ||
        targetDate.isAtSameMomentAs(fromDate)) {
      targetDate = _advanceByRecurrenceType(baseDate, payment.recurrenceType);
      return _calculateNextWeekDay(payment, targetDate);
    }

    return targetDate;
  }

  // Calcula la próxima fecha para el último día del mes
  static DateTime _calculateNextLastDayOfMonth(
    RecurringPayment payment,
    DateTime fromDate,
  ) {
    DateTime baseDate = DateTime(fromDate.year, fromDate.month, 1);
    int daysInMonth = _daysInMonth(baseDate.year, baseDate.month);
    DateTime lastDay = DateTime(baseDate.year, baseDate.month, daysInMonth);

    // Si el último día ya pasó, avanzamos según la recurrencia
    if (lastDay.isBefore(fromDate) || lastDay.isAtSameMomentAs(fromDate)) {
      DateTime nextMonth = _advanceByRecurrenceType(
        baseDate,
        payment.recurrenceType,
      );
      daysInMonth = _daysInMonth(nextMonth.year, nextMonth.month);
      return DateTime(nextMonth.year, nextMonth.month, daysInMonth);
    }

    return lastDay;
  }

  // Avanza la fecha según el tipo de recurrencia
  static DateTime _advanceByRecurrenceType(
    DateTime date,
    RecurrenceType recurrenceType,
  ) {
    switch (recurrenceType) {
      case RecurrenceType.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceType.biweekly:
        return date.add(const Duration(days: 14));
      case RecurrenceType.monthly:
        return DateTime(date.year, date.month + 1, 1);
      case RecurrenceType.bimonthly:
        return DateTime(date.year, date.month + 2, 1);
      case RecurrenceType.quarterly:
        return DateTime(date.year, date.month + 3, 1);
      case RecurrenceType.semiannual:
        return DateTime(date.year, date.month + 6, 1);
      case RecurrenceType.annual:
        return DateTime(date.year + 1, date.month, 1);
      case RecurrenceType.custom:
        // Para recurrencia personalizada, usar incremento mensual por defecto
        return DateTime(date.year, date.month + 1, 1);
    }
  }

  // Calcula el número de días en un mes específico
  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Método para calcular cuántos pagos se han realizado de un pago recurrente
  static int getCompletedPaymentsCount(RecurringPayment payment) {
    final now = DateTime.now();

    // Si la fecha de inicio es futura, no hay pagos realizados
    if (payment.startDate.isAfter(now)) {
      return 0;
    }

    // Calcular todas las fechas de pago desde el inicio hasta ahora
    List<DateTime> paymentDates = calculatePaymentDatesForPeriod(
      payment,
      payment.startDate,
      now,
    );

    // Contar cuántos pagos han pasado (son anteriores a la fecha actual)
    return paymentDates.where((date) => date.isBefore(now)).length;
  }

  // Método para calcular el número total de pagos esperados
  static int getTotalPaymentsCount(RecurringPayment payment) {
    // Si no hay fecha final, el total es indefinido (retornamos -1)
    if (payment.endDate == null) {
      return -1;
    }

    // Calcular todas las fechas de pago desde el inicio hasta la fecha final
    List<DateTime> paymentDates = calculatePaymentDatesForPeriod(
      payment,
      payment.startDate,
      payment.endDate!,
    );

    return paymentDates.length;
  }
}
