// lib/data/states/card_form_state.dart
import 'package:economia/data/enums/card_type.dart';

sealed class CardFormState {}

class CardFormInitialState extends CardFormState {}

class CardFormLoadingState extends CardFormState {}

class CardFormSuccessState extends CardFormState {
  final String message;
  CardFormSuccessState(this.message);
}

class CardFormErrorState extends CardFormState {
  final String message;
  CardFormErrorState(this.message);
}

class CardFormReadyState extends CardFormState {
  final String cardNumber;
  final String bankName;
  final CardType cardType;
  final DateTime expirationDate;
  final int paymentDay;
  final int cutOffDay;

  CardFormReadyState({
    this.cardNumber = '',
    this.bankName = '',
    this.cardType = CardType.credit,
    required this.expirationDate,
    required this.paymentDay,
    required this.cutOffDay,
  });

  CardFormReadyState copyWith({
    String? cardNumber,
    String? bankName,
    CardType? cardType,
    DateTime? expirationDate,
    int? paymentDay,
    int? cutOffDay,
  }) {
    return CardFormReadyState(
      cardNumber: cardNumber ?? this.cardNumber,
      bankName: bankName ?? this.bankName,
      cardType: cardType ?? this.cardType,
      expirationDate: expirationDate ?? this.expirationDate,
      paymentDay: paymentDay ?? this.paymentDay,
      cutOffDay: cutOffDay ?? this.cutOffDay,
    );
  }
}
