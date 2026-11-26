import 'package:batik_app/widgets/cart/cart_item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_state_view.dart';
import '../widgets/cart/cart_summary.dart';
import 'checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartController>().fetchCart();
      }
    });
  }

  Future<void> _confirmDelete(CartItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Apakah kamu yakin ingin menghapus '
            '${item.variant.product.name} dari keranjang?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final controller = context.read<CartController>();

    final success = await controller.removeItem(item.id);

    if (!mounted) return;

    _showMessage(
      success
          ? 'Produk berhasil dihapus.'
          : controller.errorMessage ?? 'Gagal menghapus produk.',
      isError: !success,
    );
  }

  Future<void> _confirmClearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kosongkan Keranjang'),
          content: const Text(
            'Semua produk dalam keranjang akan dihapus. '
            'Apakah kamu yakin?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Kosongkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final controller = context.read<CartController>();

    final success = await controller.clearCart();

    if (!mounted) return;

    _showMessage(
      success
          ? 'Keranjang berhasil dikosongkan.'
          : controller.errorMessage ?? 'Gagal mengosongkan keranjang.',
      isError: !success,
    );
  }

  Future<void> _changeQuantity(CartItemModel item, int quantity) async {
    final controller = context.read<CartController>();

    final success = await controller.updateQuantity(
      itemId: item.id,
      quantity: quantity,
    );

    if (!mounted || success) return;

    _showMessage(
      controller.errorMessage ?? 'Gagal memperbarui jumlah produk.',
      isError: true,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppTheme.error : AppTheme.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Keranjang Saya',
        actions: [
          Consumer<CartController>(
            builder: (context, controller, _) {
              if (controller.isEmpty || controller.isLoading) {
                return const SizedBox.shrink();
              }
              return TextButton.icon(
                onPressed: controller.isUpdating ? null : _confirmClearCart,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                label: const Text('Kosongkan'),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage != null && controller.cart == null) {
            return AppStateView(
              icon: Icons.cloud_off_outlined,
              title: 'Keranjang belum termuat',
              message: controller.errorMessage!,
              actionLabel: 'Coba lagi',
              onAction: controller.fetchCart,
            );
          }
          if (controller.isEmpty) {
            return AppStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'Keranjang masih kosong',
              message: 'Temukan koleksi batik dan tambahkan ke keranjang.',
              actionLabel: 'Mulai belanja',
              onAction: widget.onExplore ?? () => Navigator.maybePop(context),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.fetchCart,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.page),
              children: [
                Text(
                  '${controller.items.length} jenis produk',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final item in controller.items) ...[
                  CartItemCard(
                    key: ValueKey(item.id),
                    item: item,
                    isUpdating: controller.isUpdating,
                    onQuantityChanged: (quantity) =>
                        _changeQuantity(item, quantity),
                    onDelete: () => _confirmDelete(item),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                if (controller.errorMessage != null)
                  Text(
                    controller.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.danger),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartController>(
        builder: (context, controller, _) {
          if (controller.isLoading ||
              controller.isEmpty ||
              controller.cart == null) {
            return const SizedBox.shrink();
          }
          return CartSummary(
            totalItems: controller.totalItems,
            totalPrice: controller.totalPrice,
            onCheckout: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutView()),
            ),
          );
        },
      ),
    );
  }
}
