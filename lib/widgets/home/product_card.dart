import 'package:batik_app/models/product_model.dart';
import 'package:batik_app/views/product_detail.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  static const Color gold = Color(0xFFFFB800);
  static const Color goldDark = Color(0xFFE6A000);
  static const Color cream = Color(0xFFFFFCF5);
  static const Color textDark = Color(0xFF292929);
  static const Color textGrey = Color(0xFF898989);

  @override
  Widget build(BuildContext context) {
    // ✅ LOGIKA PO: Stok 0 dianggap Pre-Order, bukan Habis total
    final isPreOrder = product.cheapestVariant.stock <= 0;

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
          color: cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE7AE), width: 1),
          boxShadow: [
            BoxShadow(
              color: goldDark.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================
            // GAMBAR PRODUK
            // =================================
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ HERO ANIMATION untuk transisi mulus ke detail
                  Hero(
                    tag: 'product_${product.id}',
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFF4EAD5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: goldDark,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF4EAD5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 38,
                              color: Color(0xFFB5A17B),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ✅ LABEL STATUS: Pre-Order atau Tersedia
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isPreOrder ? const Color(0xFF292929) : gold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPreOrder
                                ? Icons.schedule_rounded
                                : Icons.check_circle_outline,
                            size: 14,
                            color: isPreOrder ? Colors.white : textDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPreOrder ? 'Pre-Order' : 'Tersedia',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPreOrder ? Colors.white : textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // TOMBOL FAVORIT
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur favorit belum tersedia'),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 18,
                            color: textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ✅ LAPISAN GELAP DIHAPUS agar pengguna tahu ini bisa dipesan (PO)
                ],
              ),
            ),

            // =================================
            // INFORMASI PRODUK
            // =================================
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                        height: 1.3,
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
                            product.formattedPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: goldDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: goldDark.withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Silakan hubungkan ke fitur keranjang',
                                    ),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(9),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 17,
                                  color: textDark,
                                ),
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
