import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../theme/app_theme.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late VariantModel _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Pilih varian pertama yang stoknya > 0, atau varian pertama secara default
    _selectedVariant = widget.product.variants.firstWhere(
      (v) => v.stock > 0,
      orElse: () => widget.product.variants.first,
    );
  }

  bool get isPreOrder => _selectedVariant.stock <= 0;

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // 1. HEADER GAMBAR PRODUK
          // ==========================================
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppTheme.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    size: 22,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ditambahkan ke favorit')),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFF4EAD5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE6A000),
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
                          size: 60,
                          color: Color(0xFFB5A17B),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. KONTEN DETAIL PRODUK
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  100,
                ), // Padding bawah besar untuk bottom bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Subkategori
                    Row(
                      children: [
                        if (product.category != null)
                          _buildChip(product.category!.name),
                        if (product.subcategory != null) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          _buildChip(product.subcategory!.name),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nama Produk
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Harga & Status Stok/PO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(_selectedVariant.price),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE6A000),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPreOrder
                                ? const Color(0xFF292929)
                                : const Color(0xFFFFF4E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPreOrder
                                    ? Icons.schedule_rounded
                                    : Icons.check_circle_rounded,
                                size: 16,
                                color: isPreOrder
                                    ? Colors.white
                                    : const Color(0xFFE6A000),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPreOrder
                                    ? 'Pre-Order'
                                    : 'Stok: ${_selectedVariant.stock}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isPreOrder
                                      ? Colors.white
                                      : const Color(0xFF8A8172),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32, color: Color(0xFFF0F0F0)),

                    // Pilihan Varian
                    const Text(
                      'Pilihan Varian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVariantSelector(),

                    const SizedBox(height: 24),

                    // Deskripsi
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description ??
                          'Tidak ada deskripsi untuk produk ini.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ==========================================
      // 3. BOTTOM ACTION BAR (Tetap di bawah)
      // ==========================================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQtyButton(Icons.remove, () {
                      if (_quantity > 1) setState(() => _quantity--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, () {
                      // ✅ LOGIKA PO: Quantity tetap bisa ditambah meskipun stok 0
                      setState(() => _quantity++);
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Tombol Tambah ke Keranjang
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Menambahkan ${_quantity}x ${product.name} (${_selectedVariant.name}) ${isPreOrder ? '(Pre-Order)' : ''} ke keranjang',
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
                    foregroundColor: const Color(0xFF292929),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isPreOrder
                            ? 'Pre-Order Sekarang'
                            : 'Tambah ke Keranjang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE7AE), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A8172),
        ),
      ),
    );
  }

  Widget _buildVariantSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.product.variants.map((variant) {
        final isSelected = _selectedVariant.id == variant.id;
        final isVariantPO = variant.stock <= 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedVariant = variant;
              _quantity = 1; // Reset qty saat ganti varian
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFB800) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFB800)
                    : const Color(0xFFE8E3D9),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  variant.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF292929)
                        : const Color(0xFF555555),
                  ),
                ),
                if (isVariantPO) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: Color(0xFF8A8172),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
