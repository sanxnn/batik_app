import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_network_image.dart';
import '../widgets/cart/cart_quantity_selector.dart';
import '../widgets/common/status_chip.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late ProductModel _product;
  late VariantModel _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    // Pilih varian pertama yang stoknya > 0, atau varian pertama secara default
    _selectedVariant = widget.product.variants.firstWhere(
      (v) => v.stock > 0,
      orElse: () => widget.product.variants.isEmpty
          ? widget.product.cheapestVariant
          : widget.product.variants.first,
    );
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    final result = await ProductService().getProduct(widget.product.id);
    if (!mounted || !result.isSuccess || result.data == null) return;
    setState(() {
      _product = result.data!;
      final variants = _product.variants;
      _selectedVariant = variants.isEmpty
          ? _product.cheapestVariant
          : variants.firstWhere(
              (variant) => variant.id == _selectedVariant.id,
              orElse: () => variants.firstWhere(
                (variant) => variant.stock > 0,
                orElse: () => variants.first,
              ),
            );
      if (_selectedVariant.stock > 0 && _quantity > _selectedVariant.stock) {
        _quantity = _selectedVariant.stock;
      }
    });
  }

  bool get isPreOrder => _selectedVariant.stock <= 0;

  @override
  Widget build(BuildContext context) {
    final product = _product;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // 1. HEADER GAMBAR PRODUK
          // ==========================================
          SliverAppBar(
            expandedHeight: MediaQuery.sizeOf(context).width,
            pinned: true,
            backgroundColor: AppTheme.background,
            surfaceTintColor: AppColors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Kembali',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product.id}',
                child: AppNetworkImage(
                  url: product.imageUrl,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // ==========================================
          // 2. KONTEN DETAIL PRODUK
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(color: AppColors.surface),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xl,
                  AppSpacing.page,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Subkategori
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (product.category != null)
                          _buildChip(product.category!.name),
                        if (product.subcategory != null)
                          _buildChip(product.subcategory!.name),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Nama Produk
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Harga & Status Stok/PO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            formatRupiah(_selectedVariant.price.round()),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        StatusChip(
                          label: isPreOrder
                              ? 'Pre-Order'
                              : 'Stok: ${_selectedVariant.stock}',
                          tone: AppStatusTone.warning,
                        ),
                      ],
                    ),

                    const Divider(
                      height: AppSpacing.xxl,
                      color: AppColors.border,
                    ),

                    // Pilihan Varian
                    Text(
                      'Pilihan Varian',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildVariantSelector(),

                    const SizedBox(height: AppSpacing.xl),

                    // Deskripsi
                    Text(
                      'Deskripsi Produk',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.description ??
                          'Tidak ada deskripsi untuk produk ini.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              CartQuantitySelector(
                quantity: _quantity,
                stock: _selectedVariant.stock,
                isUpdating: false,
                onChanged: (value) => setState(() => _quantity = value),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _product.variants.isEmpty
                      ? null
                      : () async {
                          final currentProduct = _product;
                          final selectedVar = _selectedVariant;

                          final success = await context
                              .read<CartController>()
                              .addToCart(
                                product: currentProduct,
                                variant: selectedVar,
                                quantity: _quantity,
                              );

                          if (!context.mounted) return;

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Menambahkan ${_quantity}x ${currentProduct.name} (${selectedVar.name}) ${isPreOrder ? '(Pre-Order)' : ''} ke keranjang',
                                ),
                                backgroundColor: AppTheme.primaryDark,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final err = context
                                .read<CartController>()
                                .errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  err ??
                                      'Gagal menambahkan produk ke keranjang',
                                ),
                                backgroundColor: AppTheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(isPreOrder ? 'Pesan sekarang' : 'Tambah ke cart'),
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

  Widget _buildChip(String label) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: AppSpacing.productMaxWidth),
    child: Chip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );

  Widget _buildVariantSelector() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _product.variants.map((variant) {
        return ChoiceChip(
          label: Text(
            variant.stock <= 0 ? '${variant.name} • PO' : variant.name,
          ),
          selected: _selectedVariant.id == variant.id,
          onSelected: (_) => setState(() {
            _selectedVariant = variant;
            _quantity = 1;
          }),
        );
      }).toList(),
    );
  }
}
