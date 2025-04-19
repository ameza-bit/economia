import 'package:economia/data/enums/payment_mode.dart';

class Concept {
  final int id;
  final String name;
  final String description;
  final String store;
  final int total;
  final PaymentMode paymentMode;
  final int months;

  Concept({
    required this.id,
    required this.name,
    this.description = '',
    this.store = 'Tienda',
    required this.total,
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
    'paymentMode': paymentMode.index,
    'months': months,
  };
}
