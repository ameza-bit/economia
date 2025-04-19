import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/models/financial_card.dart';

class Concept {
  final int id;
  final String name;
  final String description;
  final String store;
  final double total;
  final FinancialCard card;
  final PaymentMode paymentMode;
  final int months;

  Concept({
    required this.id,
    required this.name,
    this.description = '',
    this.store = 'Tienda',
    required this.total,
    required this.card,
    this.paymentMode = PaymentMode.oneTime,
    this.months = 1,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      store: json['store'] ?? 'Tienda',
      total: json['total'] ?? 0,
      card: FinancialCard.fromJson(json['card'] ?? {}),
      paymentMode: PaymentMode.values[json['paymentMode'] ?? 0],
      months: json['months'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'store': store,
    'total': total,
    'card': card.toJson(),
    'paymentMode': paymentMode.index,
    'months': months,
  };

  String get amount => "\$${total.toStringAsFixed(2)}";

  String get monthsText {
    if (months == 1) {
      return 'Mensualidad 1/$months';
    } else {
      return 'Mensualidad $months/$months';
    }
  }

  String get paymentModeText {
    if (paymentMode == PaymentMode.oneTime) {
      return 'Pago único';
    } else {
      return 'Pago mensual';
    }
  }
}
