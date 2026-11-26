import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/bundle_controller.dart';
import '../controllers/cart_controller.dart';
import '../core/utils/api_error.dart';
import '../models/bundle_model.dart';
import '../models/order_model.dart';
import '../widgets/common/content_state.dart';

class BundleDetailView extends StatefulWidget {
  final int bundleId;

  const BundleDetailView({super.key, required this.bundleId});

  @override
  State<BundleDetailView> createState() => _BundleDetailViewState();
}

class _BundleDetailViewState extends State<BundleDetailView> {
  late Future<BundleModel> _detail;
  int? _variantId;

  @override
  void initState() {
    super.initState();
    _detail = _getDetail();
  }

  Future<BundleModel> _getDetail() =>
      context.read<BundleController>().service.getBundle(widget.bundleId);

  Future<void> _add(BundleVariantModel variant) async {
    final cart = context.read<CartController>();
    final success = await cart.addToCart(variantId: variant.id, quantity: 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Paket ditambahkan ke keranjang.'
              : cart.errorMessage ?? 'Gagal menambahkan paket.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail paket')),
    body: FutureBuilder(
      future: _detail,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ContentLoading(label: 'Memuat detail paket');
        }
        if (snapshot.hasError) {
          return ContentState(
            icon: Icons.sync_problem_rounded,
            message: apiErrorMessage(snapshot.error!),
            onRetry: () => setState(() => _detail = _getDetail()),
          );
        }
        final bundle = snapshot.data!;
        final variant = bundle.variants
            .where((variant) => variant.id == _variantId)
            .firstOrNull;
        final busy = context.watch<CartController>().isUpdating;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(bundle.name, style: Theme.of(context).textTheme.titleLarge),
            if (bundle.description != null) Text(bundle.description!),
            const SizedBox(height: 12),
            if (bundle.variants.isEmpty)
              const Text('Varian paket belum tersedia.'),
            for (final option in bundle.variants)
              ListTile(
                selected: option.id == _variantId,
                leading: Icon(
                  option.id == _variantId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(option.name),
                subtitle: Text(
                  '${formatRupiah(option.price)} • Stok ${option.stock}',
                ),
                onTap: busy
                    ? null
                    : () => setState(() => _variantId = option.id),
              ),
            if (variant != null) ...[
              for (final component in variant.components)
                ListTile(
                  title: Text(component.productName),
                  subtitle: Text('${component.quantity} × ${component.name}'),
                ),
              FilledButton(
                onPressed: busy || variant.stock <= 0
                    ? null
                    : () => _add(variant),
                child: Text(
                  variant.stock > 0
                      ? 'Tambah ke keranjang'
                      : 'Stok paket habis',
                ),
              ),
            ],
          ],
        );
      },
    ),
  );
}
