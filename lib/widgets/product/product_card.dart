import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../views/product_detail.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  static const Color textDark = Color(0xFF252525);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color borderColor = Color(0xFFEAEAEA);
  static const Color imageBackground = Color(0xFFF7F7F7);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final firstVariant = product.variants.isNotEmpty
        ? product.variants.firstWhere(
            (v) => v.stock > 0,
            orElse: () => product.variants.first,
          )
        : null;

    final isPreOrder = firstVariant == null || firstVariant.stock <= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailView(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR PRODUK
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${product.id}',
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Container(
                          color: imageBackground,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: imageBackground,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Color(0xFFBBBBBB),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // STATUS PRODUK
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPreOrder ? 'Pre-Order' : 'Tersedia',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isPreOrder
                              ? const Color(0xFF777777)
                              : const Color(0xFF27845B),
                        ),
                      ),
                    ),
                  ),

                  // FAVORIT
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur favorit belum tersedia'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 17,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // INFORMASI PRODUK
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product.variants.length > 1
                          ? 'Pilihan motif tersedia'
                          : 'Batik pilihan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: textGrey),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(firstVariant?.price ?? 0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // TOMBOL KERANJANG
                        Material(
                          color: AppTheme.primaryDark,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              if (firstVariant == null) return;

                              final success = await context
                                  .read<CartController>()
                                  .addToCart(
                                    product: product,
                                    variant: firstVariant,
                                    quantity: 1,
                                  );

                              if (!context.mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${product.name} (${firstVariant.name}) ditambahkan ke keranjang!',
                                    ),
                                    backgroundColor: AppTheme.primaryDark,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              } else {
                                final err = context
                                    .read<CartController>()
                                    .errorMessage;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      err ?? 'Gagal menambahkan produk ke keranjang',
                                    ),
                                    backgroundColor: AppTheme.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
