import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title = '¡Vaya!',
    this.subtitle,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final void Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(),
          Text(
            title,
            // style: TextStyle(color: Colors.red),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary.withAlpha(200),
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}
