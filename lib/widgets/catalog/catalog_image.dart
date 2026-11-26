import 'package:flutter/material.dart';

class CatalogImage extends StatelessWidget {
  const CatalogImage({super.key, required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
      ),
    );
    return SizedBox.expand(
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.cover,
              semanticLabel: label,
              errorBuilder: (_, _, _) => placeholder,
              frameBuilder: (_, child, frame, synchronouslyLoaded) =>
                  synchronouslyLoaded || frame != null ? child : placeholder,
            ),
    );
  }
}
