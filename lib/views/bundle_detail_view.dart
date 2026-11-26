import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_controller.dart';
import '../models/bundle_model.dart';
import '../models/order_model.dart';
import '../services/bundle_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/status_chip.dart';
import '../widgets/cart/cart_quantity_selector.dart';
import '../widgets/common/app_network_image.dart';

class BundleDetailView extends StatefulWidget {
  final BundleModel bundle;

  const BundleDetailView({super.key, required this.bundle});

  @override
  State<BundleDetailView> createState() => _BundleDetailViewState();
}

class _BundleDetailViewState extends State<BundleDetailView> {
  late BundleModel _bundle;
  BundleVariantModel? _selectedVariant;
  bool _isLoading = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _bundle = widget.bundle;
    _selectedVariant = _firstAvailable(_bundle.variants);
    _refresh();
  }

  BundleVariantModel? _firstAvailable(List<BundleVariantModel> variants) {
    if (variants.isEmpty) return null;
    return variants.firstWhere(
      (variant) => variant.stock > 0,
      orElse: () => variants.first,
    );
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    BundleModel? result;
    try {
      result = await BundleService().getBundle(widget.bundle.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail paket belum dapat dimuat.')),
        );
      }
    }
    if (!mounted) return;
    if (result != null && result.variants.isNotEmpty) {
      final refreshedBundle = result;
      final selectedId = _selectedVariant?.id;
      _bundle = refreshedBundle;
      _selectedVariant = refreshedBundle.variants.firstWhere(
        (variant) => variant.id == selectedId,
        orElse: () => _firstAvailable(refreshedBundle.variants)!,
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addToCart() async {
    final variant = _selectedVariant;
    if (variant == null || variant.stock <= 0) return;
    final success = await context.read<CartController>().addToCart(
      variant: variant,
      quantity: _quantity,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Paket ditambahkan ke keranjang.'
              : context.read<CartController>().errorMessage ??
                    'Paket gagal ditambahkan.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = _selectedVariant;
    return Scaffold(
      appBar: const AppAppBar(title: 'Detail Paket'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppNetworkImage(
                      url: _bundle.imageUrl,
                      width: double.infinity,
                      height: AppSpacing.productHeight,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _bundle.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    if (_bundle.description?.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _bundle.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (variant != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        formatRupiah(variant.price),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      StatusChip(
                        label: variant.stock > 0
                            ? 'Stok ${variant.stock}'
                            : 'Pre-Order',
                        tone: AppStatusTone.warning,
                      ),
                    ],
                    if (_bundle.variants.length > 1) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Pilihan varian',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: _bundle.variants
                            .map(
                              (item) => ChoiceChip(
                                label: Text(item.name),
                                selected: item.id == variant?.id,
                                onSelected: (_) => setState(() {
                                  _selectedVariant = item;
                                  _quantity = 1;
                                }),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (variant != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Isi paket',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          children: [
                            if (variant.components.isEmpty)
                              Text(
                                'Komponen paket belum tersedia.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            for (final component in variant.components)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                                title: Text(component.productName),
                                subtitle: Text(
                                  '${component.quantity}x ${component.name}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: variant == null
          ? null
          : Container(
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
                      stock: variant.stock,
                      isUpdating: _isLoading || variant.stock <= 0,
                      onChanged: (value) => setState(() => _quantity = value),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: variant.stock > 0 && !_isLoading
                            ? _addToCart
                            : null,
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Tambah ke keranjang'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
