import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../controllers/cart_controller.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  String _activeMode = 'none'; // 'none', 'delete', atau 'checkout'
  final Set<int> _selectedItemIds = {};

  void _resetSelection() {
    setState(() {
      _activeMode = 'none';
      _selectedItemIds.clear();
    });
  }

  void _toggleSelectAll(List<CartItemModel> items) {
    setState(() {
      if (_selectedItemIds.length == items.length) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds.clear();
        for (var item in items) {
          _selectedItemIds.add(item.cartItemId);
        }
      }
    });
  }

  void _toggleSelectItem(int id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  double _calculateTotal(List<CartItemModel> items) {
    double total = 0;
    for (var item in items) {
      final price = item.variant.price;
      if (_activeMode == 'checkout') {
        if (_selectedItemIds.contains(item.cartItemId)) {
          total += (price * item.quantity);
        }
      } else {
        total += (price * item.quantity);
      }
    }
    return total;
  }

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartCtrl, _) {
        final cartItems = cartCtrl.items;
        final totalPrice = _calculateTotal(cartItems);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Keranjang Saya (${cartItems.length})',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: AppTheme.surface,
            elevation: 0.5,
            actions: [
              if (cartItems.isNotEmpty) ...[
                // 1. Icon Delete
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: _activeMode == 'delete' ? AppTheme.error : AppTheme.textPrimary,
                  ),
                  tooltip: 'Hapus Produk',
                  onPressed: () {
                    setState(() {
                      _activeMode = _activeMode == 'delete' ? 'none' : 'delete';
                      _selectedItemIds.clear();
                    });
                  },
                ),
                // 2. Icon Pembayaran
                IconButton(
                  icon: Icon(
                    Icons.payment_outlined,
                    color: _activeMode == 'checkout' ? const Color(0xFFFFB800) : AppTheme.textPrimary,
                  ),
                  tooltip: 'Mode Pembayaran',
                  onPressed: () {
                    setState(() {
                      _activeMode = _activeMode == 'checkout' ? 'none' : 'checkout';
                      _selectedItemIds.clear();
                    });
                  },
                ),
              ],
            ],
          ),
          body: cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    // Banner Indikator Mode
                    if (_activeMode != 'none')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: _activeMode == 'delete' ? Colors.red.shade50 : const Color(0xFFFFF8E1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _activeMode == 'delete'
                                  ? 'Mode Hapus (${_selectedItemIds.length} terpilih)'
                                  : 'Mode Pembayaran (${_selectedItemIds.length} terpilih)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _activeMode == 'delete' ? AppTheme.error : const Color(0xFFD9A400),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _toggleSelectAll(cartItems),
                              child: Text(
                                _selectedItemIds.length == cartItems.length ? 'Batal Semua' : 'Pilih Semua',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // List Item Keranjang
                    Expanded(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final isSelected = _selectedItemIds.contains(item.cartItemId);
                          final itemTotalPrice = item.variant.price * item.quantity;
                          final productName = item.product.name.isNotEmpty ? item.product.name : 'Batik Rubung Kuning';
                          final variantName = item.variant.name.isNotEmpty ? item.variant.name : 'Default';

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (_activeMode == 'delete' ? AppTheme.error : const Color(0xFFFFB800))
                                    : AppTheme.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                if (_activeMode != 'none') ...[
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: _activeMode == 'delete' ? AppTheme.error : const Color(0xFFFFB800),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (_) => _toggleSelectItem(item.cartItemId),
                                  ),
                                  const SizedBox(width: 4),
                                ],

                                // Image Product
                                SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFF5F5F5),
                                        child: const Center(
                                          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 24),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Product Detail & Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Varian: $variantName',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatPrice(itemTotalPrice),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFFE6A000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Buttons
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => cartCtrl.decrementQuantity(item),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => cartCtrl.incrementQuantity(item),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Bar Pembayaran
                    _buildBottomActionArea(cartCtrl, totalPrice),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.shopping_cart_outlined, size: 56, color: Color(0xFFD9A400)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Keranjang Belanjaanmu Kosong',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yuk, pilih produk batik impianmu di Beranda!',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea(CartController cartCtrl, double totalPrice) {
    if (_activeMode == 'delete') {
      return Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.surface,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedItemIds.isNotEmpty
                  ? () {
                      cartCtrl.removeSelectedItems(_selectedItemIds.toList());
                      _resetSelection();
                    }
                  : null,
              icon: const Icon(Icons.delete_forever),
              label: Text('Hapus Produk Terpilih (${_selectedItemIds.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Harga:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(
                  _formatPrice(totalPrice),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFE6A000)),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: (_activeMode == 'checkout' && _selectedItemIds.isEmpty)
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Fitur pembayaran sedang dalam proses pengembangan',
                            ),
                            backgroundColor: AppTheme.primaryDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB800),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _activeMode == 'checkout'
                      ? 'Bayar Sekarang (${_selectedItemIds.length})'
                      : 'Bayar Sekarang',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}