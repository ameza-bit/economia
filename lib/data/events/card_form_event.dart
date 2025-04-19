import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:flutter/material.dart' show BuildContext;

sealed class CardFormEvent {}

class CardFormInitEvent extends CardFormEvent {}

class CardFormLoadExistingCardEvent extends CardFormEvent {
  final FinancialCard card;
  CardFormLoadExistingCardEvent(this.card);
}

class CardFormUpdateCardNumberEvent extends CardFormEvent {
  final String cardNumber;
  CardFormUpdateCardNumberEvent(this.cardNumber);
}

class CardFormUpdateBankNameEvent extends CardFormEvent {
  final String bankName;
  CardFormUpdateBankNameEvent(this.bankName);
}

class CardFormUpdateCardTypeEvent extends CardFormEvent {
  final CardType cardType;
  CardFormUpdateCardTypeEvent(this.cardType);
}

class CardFormUpdateExpirationDateEvent extends CardFormEvent {
  final int month;
  final int year;
  CardFormUpdateExpirationDateEvent(this.month, this.year);
}

class CardFormUpdatePaymentDayEvent extends CardFormEvent {
  final int day;
  CardFormUpdatePaymentDayEvent(this.day);
}

class CardFormUpdateCutOffDayEvent extends CardFormEvent {
  final int day;
  CardFormUpdateCutOffDayEvent(this.day);
}

class CardFormUpdateAliasEvent extends CardFormEvent {
  final String alias;
  CardFormUpdateAliasEvent(this.alias);
}

class CardFormUpdateCardholderNameEvent extends CardFormEvent {
  final String cardholderName;
  CardFormUpdateCardholderNameEvent(this.cardholderName);
}

class CardFormUpdateCardNetworkEvent extends CardFormEvent {
  final CardNetwork cardNetwork;
  CardFormUpdateCardNetworkEvent(this.cardNetwork);
}

class CardFormSaveEvent extends CardFormEvent {
  final BuildContext? context;
  final bool isEditing; // Indicar si estamos editando
  final String? cardId; // ID de la tarjeta a editar
  
  CardFormSaveEvent({
    this.context, 
    this.isEditing = false, 
    this.cardId
  });
}

class CardFormDeleteEvent extends CardFormEvent {
  final String cardId;
  final BuildContext context;
  
  CardFormDeleteEvent({
    required this.cardId,
    required this.context,
  });
}