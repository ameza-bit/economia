import 'package:economia/data/models/concept.dart';
import 'package:economia/ui/widgets/general/general_card.dart';
import 'package:flutter/material.dart';

class ConceptCard extends StatelessWidget {
  const ConceptCard({super.key, required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    return GeneralCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            concept.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 2,
          ),
          Text(
            '${concept.store} - Banamex 799',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary.withAlpha(150),
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 24),
          Row(
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pago Junio 2023',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    'Mensualidad 1/6',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(150),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                concept.amount,
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
}
