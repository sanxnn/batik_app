import 'package:flutter/material.dart';

class CartQuantitySelector extends StatelessWidget {
  const CartQuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.canRequestMoreWithoutStock,
    required this.isUpdating,
    required this.onChanged,
  });

  final int quantity;
  final int stock;
  final bool canRequestMoreWithoutStock;
  final bool isUpdating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Kurangi jumlah',
            onPressed: quantity > 1 && !isUpdating
                ? () => onChanged(quantity - 1)
                : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Semantics(
            label: 'Jumlah $quantity',
            excludeSemantics: true,
            child: Text('$quantity', style: theme.textTheme.labelLarge),
          ),
          IconButton(
            tooltip: 'Tambah jumlah',
            onPressed:
                !isUpdating && (canRequestMoreWithoutStock || quantity < stock)
                ? () => onChanged(quantity + 1)
                : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
