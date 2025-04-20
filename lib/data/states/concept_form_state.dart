import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/models/financial_card.dart';

sealed class ConceptFormState {}

class ConceptFormInitialState extends ConceptFormState {}

class ConceptFormLoadingState extends ConceptFormState {}

class ConceptFormSuccessState extends ConceptFormState {
  final String message;
  ConceptFormSuccessState(this.message);
}

class ConceptFormErrorState extends ConceptFormState {
  final String message;
  ConceptFormErrorState(this.message);
}

class ConceptFormReadyState extends ConceptFormState {
  final String name;
  final String description;
  final String store;
  final String total;
  final FinancialCard? selectedCard;
  final PaymentMode paymentMode;
  final int months;
  final DateTime purchaseDate;

  ConceptFormReadyState({
    this.name = '',
    this.description = '',
    this.store = '',
    this.total = '',
    this.selectedCard,
    this.paymentMode = PaymentMode.oneTime,
    this.months = 1,
    DateTime? purchaseDate,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  ConceptFormReadyState copyWith({
    String? name,
    String? description,
    String? store,
    String? total,
    FinancialCard? selectedCard,
    PaymentMode? paymentMode,
    int? months,
    DateTime? purchaseDate,
  }) {
    return ConceptFormReadyState(
      name: name ?? this.name,
      description: description ?? this.description,
      store: store ?? this.store,
      total: total ?? this.total,
      selectedCard: selectedCard ?? this.selectedCard,
      paymentMode: paymentMode ?? this.paymentMode,
      months: months ?? this.months,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }
}
