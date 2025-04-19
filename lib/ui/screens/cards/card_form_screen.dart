import 'package:economia/data/enums/card_type.dart';
import 'package:economia/data/models/financial_card.dart';
import 'package:economia/data/repositories/card_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardFormScreen extends StatefulWidget {
  static const String routeName = 'card_form';
  const CardFormScreen({super.key});

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardRepository = CardRepository();

  late TextEditingController _cardNumberController;
  late TextEditingController _bankNameController;

  CardType _selectedCardType = CardType.credit;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 365 * 2));
  DateTime _paymentDate = DateTime.now();
  DateTime _cutOffDate = DateTime.now().subtract(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _bankNameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  void _saveCard() {
    if (_formKey.currentState!.validate()) {
      // Generar un ID simple usando timestamp
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final newCard = FinancialCard(
        id: id,
        cardNumber: int.parse(_cardNumberController.text),
        cardType: _selectedCardType,
        expirationDate: _expirationDate,
        paymentDate: _paymentDate,
        cutOffDate: _cutOffDate,
        bankName: _bankNameController.text,
      );

      _cardRepository.addCardLocal(newCard);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Tarjeta'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Tarjeta',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de tarjeta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CardType>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Tarjeta',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCardType,
                items:
                    CardType.values.map((CardType type) {
                      return DropdownMenuItem<CardType>(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                onChanged: (CardType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCardType = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Banco',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del banco';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap:
                    () => _selectDate(
                      context,
                      _expirationDate,
                      (date) => setState(() => _expirationDate = date),
                    ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Expiración',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_expirationDate.day}/${_expirationDate.month}/${_expirationDate.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap:
                    () => _selectDate(
                      context,
                      _paymentDate,
                      (date) => setState(() => _paymentDate = date),
                    ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Pago',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap:
                    () => _selectDate(
                      context,
                      _cutOffDate,
                      (date) => setState(() => _cutOffDate = date),
                    ),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Corte',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_cutOffDate.day}/${_cutOffDate.month}/${_cutOffDate.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Tarjeta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
