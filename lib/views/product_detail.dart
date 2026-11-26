import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../widgets/catalog/catalog_add_button.dart';
import '../widgets/catalog/catalog_image.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late ProductModel _product;
  VariantModel? _variant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _variant = _defaultVariant(_product);
    _refreshProduct();
  }

  VariantModel? _defaultVariant(ProductModel product) =>
      product.variants.where((variant) => variant.stock > 0).firstOrNull ??
      product.variants.firstOrNull;

  Future<void> _refreshProduct() async {
    final result = await ProductService().getProduct(widget.product.id);
    final updated = result.data;
    if (!mounted || updated == null) return;
    setState(() {
      _product = updated;
      _variant =
          updated.variants
              .where((variant) => variant.id == _variant?.id)
              .firstOrNull ??
          _defaultVariant(updated);
      final stock = _variant?.stock ?? 0;
      if (stock > 0 && _quantity > stock) _quantity = stock;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variant = _variant;
    final busy = context.select(
      (CartController controller) => controller.isUpdating,
    );
    final canPurchase = variant != null && _product.canPurchase(variant);
    final preOrder = variant != null && _product.isPreOrder(variant);
    final availability = variant == null
        ? 'Varian belum tersedia'
        : preOrder
        ? 'Pre-order'
        : variant.stock > 0
        ? 'Stok ${variant.stock}'
        : 'Stok habis';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.2,
              child: CatalogImage(url: _product.imageUrl, label: _product.name),
            ),
          ),
          const SizedBox(height: 18),
          if (_product.category case final category?)
            Text(
              category.name,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          Text(_product.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (variant != null)
            Text(
              formatRupiah(variant.price),
              style: theme.textTheme.titleLarge,
            ),
          Text(availability, style: theme.textTheme.bodyMedium),
          if (_product.variants.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Varian', style: theme.textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: [
                for (final option in _product.variants)
                  ChoiceChip(
                    selected: option.id == variant?.id,
                    label: Text(option.name),
                    onSelected: busy
                        ? null
                        : (_) => setState(() {
                            _variant = option;
                            _quantity = 1;
                          }),
                  ),
              ],
            ),
          ],
          if (canPurchase) ...[
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Jumlah'),
                IconButton(
                  tooltip: 'Kurangi jumlah',
                  onPressed: busy || _quantity <= 1
                      ? null
                      : () => setState(() => _quantity--),
                  icon: const Icon(Icons.remove_rounded),
                ),
                Text('$_quantity'),
                IconButton(
                  tooltip: 'Tambah jumlah',
                  onPressed: busy || (!preOrder && _quantity >= variant.stock)
                      ? null
                      : () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
          if (_product.description case final description?
              when description.trim().isNotEmpty) ...[
            const Divider(height: 28),
            Text('Deskripsi', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ],
      ),
      bottomNavigationBar: variant == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: CatalogAddButton(
                variantId: canPurchase ? variant.id : null,
                quantity: _quantity,
                label: preOrder
                    ? 'Pre-order'
                    : canPurchase
                    ? 'Tambah ke keranjang'
                    : 'Stok habis',
              ),
            ),
    );
  }
}
