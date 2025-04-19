import 'package:economia/data/blocs/concept_form_bloc.dart';
import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/enums/payment_mode.dart';
import 'package:economia/data/events/concept_form_event.dart';
import 'package:economia/data/models/concept.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:economia/data/repositories/concept_repository.dart';
import 'package:economia/ui/screens/concepts/concept_form_screen.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ConceptCard extends StatelessWidget {
  const ConceptCard({super.key, required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    // Formatear el monto con separador de miles
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    final formattedAmount = currencyFormat.format(concept.total);

    // Obtener el mes y año actual para mostrar
    final now = DateTime.now();
    final currentMonth = DateFormat('MMMM', 'es_MX').format(now);
    final currentYear = now.year.toString();

    final purchaseDateFormatted = DateFormat(
      'dd/MM/yyyy',
      'es_MX',
    ).format(concept.purchaseDate);

    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: concept.card.cardType.color.withAlpha(30),
      shadow: true,
      onLongPress: () => _showOptions(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con título y opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  concept.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Menú de opciones
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editConcept(context);
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

          // Información de tienda y tarjeta
          Row(
            children: [
              Icon(
                Icons.store_outlined,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  concept.store,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Información de tarjeta
          Row(
            children: [
              Icon(
                Icons.credit_card_outlined,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  concept.card.alias.isNotEmpty
                      ? '${concept.card.alias} - ${concept.card.bankName}'
                      : '${concept.card.bankName} - ****${concept.card.cardNumber.toString().substring(concept.card.cardNumber.toString().length - 4)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Fecha de compra
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Compra: $purchaseDateFormatted',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Mostrar descripción si existe
          if (concept.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    concept.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Información de pago y monto
          Row(
            children: [
              // Información de pago
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pago ${_capitalizeFirstLetter(currentMonth)} $currentYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                    ),

                    // Modo de pago
                    Text(
                      concept.paymentMode == PaymentMode.oneTime
                          ? 'Pago único'
                          : concept.monthsText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(150),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                    ),

                    // Chip de modo de pago
                    if (concept.paymentMode != PaymentMode.oneTime)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Chip(
                          label: Text(
                            _getPaymentModeText(concept.paymentMode),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: _getPaymentModeColor(
                            concept.paymentMode,
                          ),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),

              // Monto
              Text(
                formattedAmount,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
              ),
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
                title: Text('Editar concepto'),
                onTap: () {
                  Navigator.pop(context);
                  _editConcept(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Eliminar concepto',
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

  // Método para editar concepto
  void _editConcept(BuildContext context) {
    context.goNamed(
      ConceptFormScreen.routeName,
      extra: {'concept': concept, 'isEditing': true},
    );
  }

  // Método para confirmar y eliminar concepto
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Eliminar Concepto'),
            content: Text(
              '¿Estás seguro de que deseas eliminar este concepto?',
            ),
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
                  final bloc = ConceptFormBloc(
                    conceptRepository: ConceptRepository(),
                    cardRepository: CardRepository(),
                  );
                  bloc.add(
                    ConceptFormDeleteEvent(
                      conceptId: concept.id,
                      context: context,
                    ),
                  );
                },
                child: Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  // Métodos auxiliares
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getPaymentModeText(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.weekly:
        return 'Semanal';
      case PaymentMode.biweekly:
        return 'Quincenal';
      case PaymentMode.monthly:
        return 'Mensual';
      default:
        return 'Único';
    }
  }

  Color _getPaymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.weekly:
        return Colors.blue.shade100;
      case PaymentMode.biweekly:
        return Colors.purple.shade100;
      case PaymentMode.monthly:
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
