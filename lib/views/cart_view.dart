import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../widgets/cart/cart_item_card.dart';
import '../widgets/cart/cart_summary.dart';
import '../widgets/common/content_state.dart';
import 'checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CartController>().fetchCart();
    });
  }

  Future<void> _remove([CartItemModel? item]) async {
    final clearing = item == null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(clearing ? 'Kosongkan keranjang?' : 'Hapus produk?'),
        content: Text(
          clearing
              ? 'Semua barang akan dihapus dari keranjang.'
              : '${item.variant.product.name} akan dihapus dari keranjang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(
              clearing ? 'Kosongkan' : 'Hapus',
              style: TextStyle(color: Theme.of(dialog).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final cart = context.read<CartController>();
    if (cart.isUpdating || cart.isLoading) return;
    final success = clearing
        ? await cart.clearCart()
        : await cart.removeItem(item.id);
    if (!mounted) return;
    _message(
      success
          ? (clearing ? 'Keranjang dikosongkan.' : 'Produk dihapus.')
          : cart.errorMessage ?? 'Keranjang gagal diperbarui.',
    );
  }

  Future<void> _quantity(CartItemModel item, int quantity) async {
    final cart = context.read<CartController>();
    if (cart.isUpdating || cart.isLoading) return;
    final success = await cart.updateQuantity(
      itemId: item.id,
      quantity: quantity,
    );
    if (mounted && !success) {
      _message(cart.errorMessage ?? 'Jumlah gagal diperbarui.');
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final busy = cart.isUpdating || cart.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Kosongkan keranjang',
              onPressed: busy ? null : _remove,
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!cart.isUpdating && !cart.isLoading) await cart.fetchCart();
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          itemCount: cart.isEmpty ? 1 : cart.items.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (cart.isEmpty) {
              if (busy) return const ContentLoading(label: 'Memuat keranjang');
              if (cart.errorMessage case final error?) {
                return ContentState(
                  icon: Icons.sync_problem_rounded,
                  message: error,
                  onRetry: cart.fetchCart,
                );
              }
              return Column(
                children: [
                  const ContentState(
                    icon: Icons.shopping_bag_outlined,
                    message: 'Keranjang masih kosong.',
                  ),
                  OutlinedButton(
                    onPressed: widget.onBrowse,
                    child: const Text('Lihat katalog'),
                  ),
                ],
              );
            }
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.totalItems} item',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (busy)
                    const LinearProgressIndicator(
                      semanticsLabel: 'Memperbarui keranjang',
                    ),
                ],
              );
            }
            final item = cart.items[index - 1];
            return CartItemCard(
              key: ValueKey(item.id),
              item: item,
              isUpdating: busy,
              onQuantityChanged: (value) => _quantity(item, value),
              onDelete: () => _remove(item),
            );
          },
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : CartSummary(
              totalItems: cart.totalItems,
              totalPrice: cart.totalPrice,
              onCheckout: busy
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CheckoutView(),
                      ),
                    ),
            ),
    );
  }
}
