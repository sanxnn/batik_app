import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';

class CatalogAddButton extends StatefulWidget {
  const CatalogAddButton({
    super.key,
    required this.variantId,
    this.quantity = 1,
    this.label = 'Tambah ke keranjang',
    this.compact = false,
  });

  final int? variantId;
  final int quantity;
  final String label;
  final bool compact;

  @override
  State<CatalogAddButton> createState() => _CatalogAddButtonState();
}

class _CatalogAddButtonState extends State<CatalogAddButton> {
  bool _adding = false;

  Future<void> _add() async {
    final id = widget.variantId;
    if (id == null || _adding) return;
    setState(() => _adding = true);
    final cart = context.read<CartController>();
    final success = await cart.addToCart(
      variantId: id,
      quantity: widget.quantity,
    );
    if (!mounted) return;
    setState(() => _adding = false);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Ditambahkan ke keranjang'
              : cart.errorMessage ?? 'Gagal menambahkan barang.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select((CartController c) => c.isUpdating);
    final action = widget.variantId == null || busy || _adding ? null : _add;
    final icon = _adding
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.add_shopping_cart_rounded);
    final label = _adding ? 'Menambahkan…' : widget.label;
    if (widget.compact) {
      return IconButton(tooltip: label, onPressed: action, icon: icon);
    }
    return FilledButton.icon(onPressed: action, icon: icon, label: Text(label));
  }
}
