import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.cheapestVariant.stock <= 0;

    return Card(
      elevation: 0,
      color: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: const BorderSide(color: AppTheme.border, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: isOutOfStock
            ? null
            : () {
                // Navigasi ke detail produk nanti
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk dengan Badge Stok
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.surface,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surface,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: AppTheme.textHint,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Habis',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info Produk
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tampilkan nama varian termurah jika ada lebih dari 1
                  if (product.variants.length > 1)
                    Text(
                      'Mulai dari',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppTheme.textHint.withOpacity(0.2)
                              : AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: isOutOfStock
                              ? AppTheme.textHint
                              : AppTheme.primaryDark,
                        ),
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
