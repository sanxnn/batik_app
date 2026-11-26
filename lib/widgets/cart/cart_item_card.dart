import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../catalog/catalog_image.dart';
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
    final product = variant.product;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox.square(
                    dimension: 64,
                    child: CatalogImage(
                      url: product.imageUrl,
                      label: product.name,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: theme.textTheme.titleSmall),
                      Text(
                        variant.name,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Text(
                        formatRupiah(variant.price),
                        style: theme.textTheme.labelLarge,
                      ),
                      if (variant.isBundle && variant.stock == 0)
                        Text(
                          'Stok paket habis',
                          style: TextStyle(color: scheme.error),
                        )
                      else if (variant.stock > 0)
                        Text(
                          'Stok ${variant.stock}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus ${product.name}',
                  onPressed: isUpdating ? null : onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                CartQuantitySelector(
                  quantity: item.quantity,
                  stock: variant.stock,
                  canRequestMoreWithoutStock: item.canRequestMoreWithoutStock,
                  isUpdating: isUpdating,
                  onChanged: onQuantityChanged,
                ),
                Text(
                  'Subtotal ${formatRupiah(item.subtotal)}',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
