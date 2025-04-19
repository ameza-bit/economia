import 'package:economia/data/enums/card_type.dart';

class FinancialCard {
  final String id;
  final int cardNumber;
  final CardType cardType;
  final DateTime expirationDate;
  final DateTime paymentDate;
  final DateTime cutOffDate;
  final String bankName;

  FinancialCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.expirationDate,
    required this.paymentDate,
    required this.cutOffDate,
    required this.bankName,
  });

  factory FinancialCard.fromJson(Map<String, dynamic> json) => FinancialCard(
    id: json['id'] ?? '',
    cardNumber: json['cardNumber'] ?? 0,
    cardType: CardType.values[json['cardType'] ?? 0],
    expirationDate:
        DateTime.tryParse(json['expirationDate'] ?? '') ?? DateTime.now(),
    paymentDate: DateTime.tryParse(json['paymentDate'] ?? '') ?? DateTime.now(),
    cutOffDate: DateTime.tryParse(json['cutOffDate'] ?? '') ?? DateTime.now(),
    bankName: json['bankName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardNumber': cardNumber,
    'cardType': cardType.index,
    'expirationDate': expirationDate.toIso8601String(),
    'paymentDate': paymentDate.toIso8601String(),
    'cutOffDate': cutOffDate.toIso8601String(),
    'bankName': bankName,
  };
}
