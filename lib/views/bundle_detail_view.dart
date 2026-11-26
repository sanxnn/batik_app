import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/bundle_controller.dart';
import '../controllers/cart_controller.dart';
import '../core/utils/api_error.dart';
import '../models/bundle_model.dart';
import '../models/order_model.dart';
import '../widgets/common/content_state.dart';
import '../widgets/catalog/catalog_add_button.dart';
import '../widgets/catalog/catalog_image.dart';

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
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1.4,
                      child: CatalogImage(
                        url: bundle.imageUrl,
                        label: bundle.name,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bundle.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (bundle.description != null) Text(bundle.description!),
                  const SizedBox(height: 12),
                  if (bundle.variants.isEmpty)
                    const Text('Varian paket belum tersedia.')
                  else
                    Text(
                      'Varian paket',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                        subtitle: Text(
                          '${component.quantity} × ${component.name}',
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (variant != null)
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: CatalogAddButton(
                  variantId: variant.stock > 0 ? variant.id : null,
                  label: variant.stock > 0
                      ? 'Tambah ke keranjang'
                      : 'Stok paket habis',
                ),
              ),
          ],
        );
      },
    ),
  );
}
