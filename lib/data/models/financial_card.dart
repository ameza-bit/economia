import 'package:economia/data/enums/card_type.dart';

class FinancialCard {
  final String id;
  final int cardNumber;
  final CardType cardType;
  final DateTime expirationDate;
  final int paymentDay;
  final int cutOffDay;
  final String bankName;

  FinancialCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.expirationDate,
    required this.paymentDay,
    required this.cutOffDay,
    required this.bankName,
  });

  factory FinancialCard.fromJson(Map<String, dynamic> json) => FinancialCard(
    id: json['id'] ?? '',
    cardNumber: json['cardNumber'] ?? 0,
    cardType: CardType.values[json['cardType'] ?? 0],
    expirationDate:
        DateTime.tryParse(json['expirationDate'] ?? '') ?? DateTime.now(),
    paymentDay: json['paymentDay'] ?? 1,
    cutOffDay: json['cutOffDay'] ?? 15,
    bankName: json['bankName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardNumber': cardNumber,
    'cardType': cardType.index,
    'expirationDate': expirationDate.toIso8601String(),
    'paymentDay': paymentDay,
    'cutOffDay': cutOffDay,
    'bankName': bankName,
  };
}
