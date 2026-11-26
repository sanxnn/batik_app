import 'package:flutter/material.dart';

class ContentState extends StatelessWidget {
  const ContentState({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 32),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class ContentLoading extends StatelessWidget {
  const ContentLoading({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(semanticsLabel: label));
}
