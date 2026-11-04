import 'package:batik_app/widgets/cart/cart_item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../theme/app_theme.dart';
import '../widgets/cart/cart_summary.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

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
            borderRadius: BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
            borderRadius: BorderRadius.circular(18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Kosongkan',
                style: TextStyle(color: Colors.red),
              ),
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
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20,
          ),
        ),
        actions: [
          Consumer<CartController>(
            builder: (context, controller, child) {
              if (controller.isEmpty || controller.isLoading) {
                return const SizedBox.shrink();
              }

              return TextButton.icon(
                onPressed: controller.isUpdating ? null : _confirmClearCart,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'Kosongkan',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Consumer<CartController>(
        builder: (context, controller, child) {
          // Loading
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE6A000)),
            );
          }

          // Error saat mengambil keranjang
          if (controller.errorMessage != null && controller.cart == null) {
            return _buildError(controller.errorMessage!);
          }

          // Keranjang kosong
          if (controller.isEmpty) {
            return _buildEmptyCart();
          }

          // Daftar produk
          return RefreshIndicator(
            color: const Color(0xFFE6A000),
            onRefresh: controller.fetchCart,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFFE6A000),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${controller.items.length} jenis produk',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ...controller.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: CartItemCard(
                      key: ValueKey(item.id),
                      item: item,
                      isUpdating: controller.isUpdating,
                      onQuantityChanged: (quantity) {
                        _changeQuantity(item, quantity);
                      },
                      onDelete: () {
                        _confirmDelete(item);
                      },
                    ),
                  );
                }),

                if (controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: Consumer<CartController>(
        builder: (context, controller, child) {
          if (controller.isLoading ||
              controller.isEmpty ||
              controller.cart == null) {
            return const SizedBox.shrink();
          }

          return CartSummary(
            totalItems: controller.totalItems,
            totalPrice: controller.totalPrice,
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 65,
                color: Color(0xFFE6A000),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Keranjang Masih Kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Yuk, temukan koleksi batik favoritmu '
              'dan tambahkan ke keranjang.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB800),
                foregroundColor: const Color(0xFF292929),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Keranjang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CartController>().fetchCart();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
