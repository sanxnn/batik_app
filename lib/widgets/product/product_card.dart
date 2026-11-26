import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../views/product_detail.dart';
import '../common/app_network_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final variant = product.variants.isEmpty
        ? null
        : product.variants.firstWhere(
            (item) => item.stock > 0,
            orElse: () => product.variants.first,
          );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${product.id}',
                    child: AppNetworkImage(url: product.imageUrl),
                  ),
                  if (variant != null)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxs,
                          ),
                          child: Text(
                            variant.stock > 0 ? 'Tersedia' : 'Pre-order',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.ink),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          variant == null
                              ? 'Harga belum tersedia'
                              : formatRupiah(variant.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      IconButton.filled(
                        tooltip: 'Tambah ${product.name} ke keranjang',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.brandYellow,
                          foregroundColor: AppColors.ink,
                          disabledBackgroundColor: AppColors.surfaceMuted,
                          disabledForegroundColor: AppColors.disabled,
                        ),
                        onPressed: variant == null
                            ? null
                            : () async {
                                final success = await context
                                    .read<CartController>()
                                    .addToCart(
                                      product: product,
                                      variant: variant,
                                      quantity: 1,
                                    );
                                if (!context.mounted) return;
                                final error = context
                                    .read<CartController>()
                                    .errorMessage;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? '${product.name} ditambahkan ke keranjang.'
                                          : error ??
                                                'Gagal menambahkan produk.',
                                    ),
                                    backgroundColor: success
                                        ? AppColors.ink
                                        : AppColors.danger,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.shopping_bag_outlined),
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
