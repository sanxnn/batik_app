
import 'package:flutter/material.dart';

class CartQuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final bool isUpdating;
  final ValueChanged<int> onChanged;

  const CartQuantitySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.isUpdating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canIncrease = stock <= 0 || quantity < stock;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            icon: Icons.remove,
            enabled: quantity > 1 && !isUpdating,
            onTap: () => onChanged(quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          _button(
            icon: Icons.add,
            enabled: canIncrease && !isUpdating,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF292929) : Colors.grey,
        ),
      ),
    );
  }
}
