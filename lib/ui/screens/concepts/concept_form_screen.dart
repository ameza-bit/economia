import 'package:flutter/material.dart';

class ConceptFormScreen extends StatefulWidget {
  static const String routeName = 'concept_form';
  const ConceptFormScreen({super.key});

  @override
  State<ConceptFormScreen> createState() => _ConceptFormScreenState();
}

class _ConceptFormScreenState extends State<ConceptFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Concept Form'), centerTitle: true),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Concept Form Screen')),
      ),
    );
  }
}
