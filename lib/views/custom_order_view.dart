import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/custom_order_controller.dart';
import '../theme/app_theme.dart';
import 'order_detail_view.dart';

class CustomOrderView extends StatefulWidget {
  const CustomOrderView({super.key});

  @override
  State<CustomOrderView> createState() => _CustomOrderViewState();
}

class _CustomOrderViewState extends State<CustomOrderView> {
  final _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomOrderController>().load(refresh: true);
      context.read<AddressController>().fetchAddresses();
    });
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final text = _description.text.trim();
    if (text.length < 10) {
      _message('Deskripsi minimal 10 karakter.', error: true);
      return;
    }
    final created = await context.read<CustomOrderController>().create(text);
    if (!mounted) return;
    if (created == null) {
      _message(
        context.read<CustomOrderController>().errorMessage ??
            'Custom order gagal dibuat.',
        error: true,
      );
      return;
    }
    _description.clear();
    _message('Permintaan custom order berhasil dikirim.');
  }

  Future<void> _approve(int id) async {
    final addresses = context.read<AddressController>();
    if (addresses.addresses.isEmpty) {
      _message('Tambahkan alamat sebelum menyetujui quotation.', error: true);
      return;
    }
    final addressId =
        addresses.primaryAddress?.id ?? addresses.addresses.first.id;
    final orderId = await context.read<CustomOrderController>().approve(
      id,
      addressId: addressId,
    );
    if (!mounted) return;
    if (orderId == null) {
      _message(
        context.read<CustomOrderController>().errorMessage ??
            'Quotation gagal disetujui.',
        error: true,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailView(orderId: orderId)),
    );
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppTheme.error : AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CustomOrderController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Order')),
      body: RefreshIndicator(
        onRefresh: () => controller.load(refresh: true),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Pesan produk sesuai kebutuhanmu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jelaskan motif, warna, ukuran, dan kebutuhan lainnya. Admin akan meninjau dan mengirim quotation.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Deskripsi pesanan',
                hintText: 'Contoh: batik tulis motif bunga warna biru...',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.isSaving ? null : _create,
              child: Text(
                controller.isSaving ? 'Mengirim...' : 'Kirim custom order',
              ),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                style: const TextStyle(color: AppTheme.error),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Riwayat custom order',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (controller.isLoading && controller.orders.isEmpty)
              const Center(child: CircularProgressIndicator()),
            for (final order in controller.orders)
              Card(
                child: ListTile(
                  title: Text(order.referenceNumber),
                  subtitle: Text('${order.status} • ${order.description}'),
                  isThreeLine: true,
                  trailing: order.status == 'quoted'
                      ? TextButton(
                          onPressed: () => _approve(order.id),
                          child: const Text('Setujui'),
                        )
                      : null,
                ),
              ),
            if (controller.canLoadMore)
              TextButton(
                onPressed: () => controller.load(),
                child: const Text('Muat lainnya'),
              ),
          ],
        ),
      ),
    );
  }
}
