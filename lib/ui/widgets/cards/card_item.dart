import 'package:economia/data/blocs/card_form_bloc.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/card_network.dart';
import 'package:economia/data/events/card_form_event.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/ui/screens/cards/card_form_screen.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardItem extends StatelessWidget {
  final FinancialCard card;

  const CardItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // Verificar si es una tarjeta de crédito para mostrar días de pago/corte
    final bool isCredit =
        card.cardType == CardType.credit || card.cardType == CardType.other;

    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: card.cardType.color.withAlpha(50),
      shadow: true,
      // Agregar onLongPress para mostrar opciones
      onLongPress: () => _showOptions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título y opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Alias de la tarjeta (si existe)
              Expanded(
                child:
                    card.alias.isNotEmpty
                        ? Text(
                          card.alias,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                        : Text(
                          card.bankName,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
              // Menú de opciones
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editCard(context);
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),

          // Resto del contenido de la tarjeta (mantener el código existente)
          // ...

          // Información bancaria y tipo de tarjeta
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card.bankName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                  Text(
                    card.cardNetwork.displayName,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ],
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

          // Nombre del titular
          Text(
            card.cardholderName.isNotEmpty
                ? card.cardholderName.toUpperCase()
                : 'TITULAR NO ESPECIFICADO',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

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

              // Solo mostrar días de pago y corte para tarjetas de crédito u otro tipo
              if (isCredit) ...[
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
            ],
          ),
        ],
      ),
    );
  }

  // Método para mostrar opciones en modal
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar tarjeta'),
                onTap: () {
                  Navigator.pop(context);
                  _editCard(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Eliminar tarjeta',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
    );
  }

  // Método para editar tarjeta
  void _editCard(BuildContext context) {
    context.goNamed(
      CardFormScreen.routeName,
      extra: {'card': card, 'isEditing': true},
    );
  }

  // Método para confirmar y eliminar tarjeta
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar Tarjeta'),
            content: Text('¿Estás seguro de que deseas eliminar esta tarjeta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // Crear un bloc temporal para manejar la eliminación
                  final bloc = CardFormBloc(CardRepository());
                  bloc.add(
                    CardFormDeleteEvent(cardId: card.id, context: context),
                  );
                },
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
