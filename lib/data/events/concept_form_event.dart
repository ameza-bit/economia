import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:flutter/material.dart' show BuildContext;

sealed class ConceptFormEvent {}

class ConceptFormInitEvent extends ConceptFormEvent {}

class ConceptFormUpdateNameEvent extends ConceptFormEvent {
  final String name;
  ConceptFormUpdateNameEvent(this.name);
}

class ConceptFormUpdateDescriptionEvent extends ConceptFormEvent {
  final String description;
  ConceptFormUpdateDescriptionEvent(this.description);
}

class ConceptFormUpdateStoreEvent extends ConceptFormEvent {
  final String store;
  ConceptFormUpdateStoreEvent(this.store);
}

class ConceptFormUpdateTotalEvent extends ConceptFormEvent {
  final String total;
  ConceptFormUpdateTotalEvent(this.total);
}

class ConceptFormUpdateSelectedCardEvent extends ConceptFormEvent {
  final FinancialCard card;
  ConceptFormUpdateSelectedCardEvent(this.card);
}

class ConceptFormUpdatePaymentModeEvent extends ConceptFormEvent {
  final PaymentMode paymentMode;
  ConceptFormUpdatePaymentModeEvent(this.paymentMode);
}

class ConceptFormUpdateMonthsEvent extends ConceptFormEvent {
  final int months;
  ConceptFormUpdateMonthsEvent(this.months);
}

class ConceptFormLoadExistingConceptEvent extends ConceptFormEvent {
  final int conceptId;
  ConceptFormLoadExistingConceptEvent(this.conceptId);
}

class ConceptFormSaveEvent extends ConceptFormEvent {
  final BuildContext? context;
  final bool isEditing;
  final int? conceptId;

  ConceptFormSaveEvent({this.context, this.isEditing = false, this.conceptId});
}

class ConceptFormDeleteEvent extends ConceptFormEvent {
  final int conceptId;
  final BuildContext context;

  ConceptFormDeleteEvent({required this.conceptId, required this.context});
}
