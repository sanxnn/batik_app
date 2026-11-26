import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class CartQuantitySelector extends StatelessWidget {
  const CartQuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.isUpdating,
    required this.onChanged,
  });

  final int quantity;
  final int stock;
  final bool isUpdating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canIncrease = stock <= 0 || quantity < stock;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 && !isUpdating
                ? () => onChanged(quantity - 1)
                : null,
            tooltip: 'Kurangi jumlah',
            icon: const Icon(Icons.remove_rounded),
            constraints: const BoxConstraints(
              minWidth: AppSpacing.touchTarget,
              minHeight: AppSpacing.touchTarget,
            ),
          ),
          Text(
            quantity.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          IconButton(
            onPressed: canIncrease && !isUpdating
                ? () => onChanged(quantity + 1)
                : null,
            tooltip: 'Tambah jumlah',
            icon: const Icon(Icons.add_rounded),
            constraints: const BoxConstraints(
              minWidth: AppSpacing.touchTarget,
              minHeight: AppSpacing.touchTarget,
            ),
          ),
        ],
      ),
    );
  }
}
