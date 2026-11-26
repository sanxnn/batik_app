import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../common/app_card.dart';
import '../common/app_network_image.dart';
import '../common/status_chip.dart';
import 'cart_quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.isUpdating,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  final CartItemModel item;
  final bool isUpdating;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final variant = item.variant;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                url: variant.product.imageUrl,
                width: AppSpacing.categoryHeight,
                height: AppSpacing.categoryHeight,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      variant.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    StatusChip(
                      label: item.isPreOrder
                          ? 'Pre-Order'
                          : 'Stok ${variant.stock}',
                      tone: AppStatusTone.warning,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isUpdating ? null : onDelete,
                tooltip: 'Hapus ${variant.product.name}',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatRupiah(variant.price),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      'Subtotal ${formatRupiah(item.subtotal)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              CartQuantitySelector(
                quantity: item.quantity,
                stock: variant.stock,
                isUpdating: isUpdating,
                onChanged: onQuantityChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
