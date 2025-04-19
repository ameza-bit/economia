// lib/ui/widgets/cards/card_item.dart
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';

class CardItem extends StatelessWidget {
  final FinancialCard card;

  const CardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: card.cardType.color.withAlpha(50),
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información bancaria
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                card.bankName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Chip(
                label: Text(
                  card.cardType.displayName,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: card.cardType.color,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Número de tarjeta (formateado)
          Text(
            '•••• •••• •••• ${card.cardNumber.toString().substring(card.cardNumber.toString().length - 4)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: 16),

          // Fechas importantes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fecha de expiración
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRA',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${card.expirationDate.month.toString().padLeft(2, '0')}/${card.expirationDate.year.toString().substring(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              // Día de pago
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAGO',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Día ${card.paymentDay}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),

              // Día de corte
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CORTE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Día ${card.cutOffDay}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
