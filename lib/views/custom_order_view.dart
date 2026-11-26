import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';

import '../controllers/address_controller.dart';
import '../controllers/custom_order_controller.dart';
import '../theme/app_theme.dart';
import '../core/network/image_url.dart';
import '../core/utils/image_files.dart';
import '../models/custom_order_model.dart';
import '../models/order_model.dart';
import 'address_view.dart';
import 'order_detail_view.dart';

class CustomOrderView extends StatefulWidget {
  const CustomOrderView({super.key});

  @override
  State<CustomOrderView> createState() => _CustomOrderViewState();
}

class _CustomOrderViewState extends State<CustomOrderView> {
  final _description = TextEditingController();
  List<XFile> _attachments = [];
  bool _pickingFiles = false;

  Future<List<XFile>> _pickFiles(int limit) async {
    setState(() => _pickingFiles = true);
    try {
      final files = await openFiles(acceptedTypeGroups: [commerceImages]);
      if (!mounted || files.isEmpty) return [];
      if (files.length > limit) {
        _message('Anda dapat memilih maksimal $limit foto.', error: true);
        return [];
      }
      for (final file in files) {
        if (!await isSupportedImage(file, 2 * 1024 * 1024)) {
          if (mounted) {
            _message(
              'Gunakan JPEG, PNG, atau WebP maksimal 2 MB per foto.',
              error: true,
            );
          }
          return [];
        }
      }
      return files;
    } catch (error) {
      if (mounted) _message('Foto tidak dapat dibuka.', error: true);
      return [];
    } finally {
      if (mounted) setState(() => _pickingFiles = false);
    }
  }

  Future<void> _append(CustomOrderModel order) async {
    final files = await _pickFiles(5 - order.attachmentPaths.length);
    if (!mounted || files.isEmpty) return;
    final controller = context.read<CustomOrderController>();
    final success = await controller.addAttachments(order.id, files);
    if (mounted) {
      _message(
        success
            ? 'Lampiran ditambahkan.'
            : controller.errorMessage ?? 'Gagal menambah lampiran.',
        error: !success,
      );
    }
  }

  Future<void> _cancel(CustomOrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan custom order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final controller = context.read<CustomOrderController>();
    final success = await controller.cancel(order.id);
    if (mounted) {
      _message(
        success
            ? 'Custom order dibatalkan.'
            : controller.errorMessage ?? 'Gagal membatalkan.',
        error: !success,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
    final created = await context.read<CustomOrderController>().create(
      text,
      attachments: _attachments,
    );
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
    setState(() => _attachments = []);
    _message('Permintaan custom order berhasil dikirim.');
  }

  Future<void> _approve(CustomOrderModel order) async {
    final addresses = context.read<AddressController>();
    await addresses.fetchAddresses();
    if (!mounted) return;
    if (addresses.errorMessage != null) {
      _message(addresses.errorMessage!, error: true);
      return;
    }
    if (addresses.addresses.isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddressView()),
      );
      return;
    }
    final selection = await showDialog<({int addressId, String notes})>(
      context: context,
      builder: (context) => _QuotationDialog(addresses: addresses),
    );
    if (!mounted || selection == null) return;
    final orderId = await context.read<CustomOrderController>().approve(
      order.id,
      addressId: selection.addressId,
      notes: selection.notes,
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
    final busy = controller.isSaving || _pickingFiles;
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
              enabled: !busy,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Deskripsi pesanan',
                hintText: 'Contoh: batik tulis motif bunga warna biru...',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final files = await _pickFiles(5);
                      if (mounted && files.isNotEmpty) {
                        setState(() => _attachments = files);
                      }
                    },
              child: Text(
                _attachments.isEmpty
                    ? 'Pilih lampiran (opsional)'
                    : 'Ganti lampiran',
              ),
            ),
            for (final file in _attachments)
              ListTile(
                title: Text(file.name),
                trailing: IconButton(
                  tooltip: 'Hapus lampiran',
                  onPressed: busy
                      ? null
                      : () => setState(() => _attachments.remove(file)),
                  icon: const Icon(Icons.close),
                ),
              ),
            FilledButton(
              onPressed: busy ? null : _create,
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
                child: ExpansionTile(
                  title: Text(order.referenceNumber),
                  subtitle: Text(order.statusLabel),
                  childrenPadding: const EdgeInsets.all(16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.description),
                    if (order.estimatedPrice case final price?)
                      Text('Penawaran: ${formatRupiah(price)}'),
                    if (order.estimatedTime case final time?)
                      Text('Estimasi: $time'),
                    if (order.adminNotes case final notes?)
                      Text('Catatan admin: $notes'),
                    if (order.attachmentPaths.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final path in order.attachmentPaths)
                            Image.network(
                              productImageUrl(path),
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.broken_image_outlined),
                            ),
                        ],
                      ),
                    if (order.status == 'pending_review' &&
                        order.attachmentPaths.length < 5)
                      TextButton(
                        onPressed: busy ? null : () => _append(order),
                        child: const Text('Tambah lampiran'),
                      ),
                    if (order.status == 'quoted')
                      FilledButton(
                        onPressed: busy ? null : () => _approve(order),
                        child: const Text('Setujui penawaran'),
                      ),
                    if (order.status == 'pending_review' ||
                        order.status == 'quoted')
                      TextButton(
                        onPressed: busy ? null : () => _cancel(order),
                        child: const Text('Batalkan custom order'),
                      ),
                    if (order.orderId case final id?)
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailView(orderId: id),
                          ),
                        ),
                        child: const Text('Lihat pesanan'),
                      ),
                  ],
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

class _QuotationDialog extends StatefulWidget {
  final AddressController addresses;
  const _QuotationDialog({required this.addresses});

  @override
  State<_QuotationDialog> createState() => _QuotationDialogState();
}

class _QuotationDialogState extends State<_QuotationDialog> {
  late int _addressId =
      widget.addresses.primaryAddress?.id ??
      widget.addresses.addresses.first.id;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Setujui penawaran'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _addressId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Alamat pengiriman'),
            items: [
              for (final address in widget.addresses.addresses)
                DropdownMenuItem(
                  value: address.id,
                  child: Text(
                    '${address.label} • ${address.recipientName} • ${address.detail}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) _addressId = value;
            },
          ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          const Text(
            'Harga akhir mencakup ongkir yang dihitung setelah penawaran disetujui.',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Kembali'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, (addressId: _addressId, notes: _notes.text)),
        child: const Text('Setujui dan buat pesanan'),
      ),
    ],
  );
}
