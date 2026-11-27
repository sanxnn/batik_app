import 'dart:async';

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
  bool _added = false;
  Timer? _feedbackTimer;

  @override
  void didUpdateWidget(CatalogAddButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variantId != widget.variantId ||
        oldWidget.quantity != widget.quantity) {
      _feedbackTimer?.cancel();
      _added = false;
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _add() async {
    final id = widget.variantId;
    if (id == null || _adding) return;
    final quantity = widget.quantity;
    _feedbackTimer?.cancel();
    setState(() {
      _adding = true;
      _added = false;
    });
    final cart = context.read<CartController>();
    final success = await cart.addToCart(variantId: id, quantity: quantity);
    if (!mounted) return;
    setState(() {
      _adding = false;
      _added = success && widget.variantId == id && widget.quantity == quantity;
    });
    if (_added) {
      _feedbackTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) setState(() => _added = false);
      });
    }
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final glyph = _adding
        ? const SizedBox.square(
            key: ValueKey('loading'),
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _added
        ? const Icon(Icons.check_rounded, key: ValueKey('added'))
        : const Icon(Icons.add_shopping_cart_rounded, key: ValueKey('add'));
    final icon = reduceMotion
        ? glyph
        : AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: glyph,
          );
    final label = _adding ? 'Menambahkan…' : widget.label;
    if (widget.compact) {
      return IconButton(tooltip: label, onPressed: action, icon: icon);
    }
    return FilledButton.icon(onPressed: action, icon: icon, label: Text(label));
  }
}
