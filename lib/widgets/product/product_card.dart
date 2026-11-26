import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../views/product_detail.dart';
import '../catalog/catalog_image.dart';
import '../catalog/catalog_add_button.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inStock = product.variants.any((variant) => variant.stock > 0);
    final preOrder = product.variants.any(product.isPreOrder);
    final availability = inStock
        ? 'Tersedia'
        : (preOrder ? 'Pre-order' : 'Stok habis');
    final single = product.variants.length == 1 ? product.variants.first : null;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailView(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: CatalogImage(url: product.imageUrl, label: product.name),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    availability,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: preOrder && !inStock
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (product.variants.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.variants.length == 1
                                ? product.formattedPrice
                                : 'Mulai ${product.formattedPrice}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        if (single != null && product.canPurchase(single))
                          CatalogAddButton(
                            variantId: single.id,
                            compact: true,
                            label: product.isPreOrder(single)
                                ? 'Pre-order ${product.name}'
                                : 'Tambah ${product.name} ke keranjang',
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
