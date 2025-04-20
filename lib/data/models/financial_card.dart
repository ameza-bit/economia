import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';

class FinancialCard {
  final String id;
  final int cardNumber;
  final CardType cardType;
  final DateTime expirationDate;
  final int paymentDay;
  final int cutOffDay;
  final String bankName;
  final String alias;
  final String cardholderName;
  final CardNetwork cardNetwork;

  FinancialCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.expirationDate,
    required this.paymentDay,
    required this.cutOffDay,
    required this.bankName,
    required this.alias,
    required this.cardholderName,
    required this.cardNetwork,
  });

  factory FinancialCard.fromJson(Map<String, dynamic> json) => FinancialCard(
    id: json['id'] ?? '',
    cardNumber: json['cardNumber'] ?? 0,
    cardType:
        json['cardType'] != null
            ? CardType.values[json['cardType']]
            : CardType.other,
    expirationDate:
        DateTime.tryParse(json['expirationDate'] ?? '') ?? DateTime.now(),
    paymentDay: json['paymentDay'] ?? 1,
    cutOffDay: json['cutOffDay'] ?? 15,
    bankName: json['bankName'] ?? '',
    alias: json['alias'] ?? '',
    cardholderName: json['cardholderName'] ?? '',
    cardNetwork:
        json['cardNetwork'] != null
            ? CardNetwork.values[json['cardNetwork']]
            : CardNetwork.other,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardNumber': cardNumber,
    'cardType': cardType.index,
    'expirationDate': expirationDate.toIso8601String(),
    'paymentDay': paymentDay,
    'cutOffDay': cutOffDay,
    'bankName': bankName,
    'alias': alias,
    'cardholderName': cardholderName,
    'cardNetwork': cardNetwork.index,
  };

  // Agregar estos métodos para comparación
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FinancialCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
