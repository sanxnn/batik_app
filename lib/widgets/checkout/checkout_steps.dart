import 'package:flutter/material.dart';

class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.step});

  final int step;

  static const _labels = ['Alamat', 'Tinjau', 'Bayar'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: 'Langkah $step dari 3, ${_labels[step - 1]}',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < _labels.length; index++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: index < step
                              ? scheme.secondary
                              : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const SizedBox(height: 4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${index + 1} ${_labels[index]}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: index == step - 1
                              ? scheme.secondary
                              : scheme.onSurfaceVariant,
                          fontWeight: index == step - 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
