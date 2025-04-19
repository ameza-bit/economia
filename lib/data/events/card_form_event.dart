// lib/data/events/card_form_event.dart
import 'package:economia/data/enums/card_type.dart';
import 'package:flutter/material.dart' show BuildContext;

sealed class CardFormEvent {}

class CardFormInitEvent extends CardFormEvent {}

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

class CardFormSaveEvent extends CardFormEvent {
  final BuildContext? context;
  CardFormSaveEvent({this.context});
}
