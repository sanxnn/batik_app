
import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import 'cart_quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isUpdating;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isUpdating,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final variant = item.variant;
    final product = variant.product;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.imageUrl,
              width: 90,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90,
                height: 100,
                color: const Color(0xFFF4EAD5),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFB5A17B),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Informasi produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF292929),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Varian: ${variant.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8172),
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isPreOrder
                        ? const Color(0xFF292929)
                        : const Color(0xFFFFF4E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isPreOrder
                        ? 'Pre-Order'
                        : 'Stok: ${variant.stock}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: item.isPreOrder
                          ? Colors.white
                          : const Color(0xFF8A8172),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _formatPrice(variant.price),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE6A000),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    CartQuantitySelector(
                      quantity: item.quantity,
                      stock: variant.stock,
                      isUpdating: isUpdating,
                      onChanged: onQuantityChanged,
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: isUpdating ? null : onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 21,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Subtotal: ${_formatPrice(item.subtotal)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
