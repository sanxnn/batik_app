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
import '../widgets/auth/auth_button.dart';
import '../widgets/catalog/catalog_image.dart';
import '../widgets/common/content_state.dart';
import '../widgets/common/form_error.dart';
import '../widgets/orders/lifecycle_badge.dart';
import 'address_view.dart';
import 'order_detail_view.dart';

class CustomOrderView extends StatefulWidget {
  const CustomOrderView({super.key});

  @override
  State<CustomOrderView> createState() => _CustomOrderViewState();
}

class _CustomOrderViewState extends State<CustomOrderView> {
  final _description = TextEditingController();
  final _requestForm = GlobalKey<FormState>();
  bool _preparingQuote = false;
  String? _submitError;
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
    });
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_requestForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);
    final text = _description.text.trim();
    final created = await context.read<CustomOrderController>().create(
      text,
      attachments: _attachments,
    );
    if (!mounted) return;
    if (created == null) {
      setState(
        () => _submitError =
            context.read<CustomOrderController>().errorMessage ??
            'Custom order gagal dibuat.',
      );
      return;
    }
    _description.clear();
    setState(() => _attachments = []);
    _message('Permintaan custom order berhasil dikirim.');
  }

  Future<void> _approve(CustomOrderModel order) async {
    if (_preparingQuote) return;
    setState(() => _preparingQuote = true);
    final addresses = context.read<AddressController>();
    try {
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
        builder: (_) => _QuotationDialog(addresses: addresses, order: order),
      );
      if (!mounted || selection == null) return;
      final controller = context.read<CustomOrderController>();
      final orderId = await controller.approve(
        order.id,
        addressId: selection.addressId,
        notes: selection.notes,
      );
      if (!mounted) return;
      if (orderId == null) {
        _message(
          controller.errorMessage ?? 'Penawaran gagal disetujui.',
          error: true,
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OrderDetailView(orderId: orderId)),
      );
    } finally {
      if (mounted) setState(() => _preparingQuote = false);
    }
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
    final busy = controller.isSaving || _pickingFiles || _preparingQuote;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Order')),
      body: RefreshIndicator(
        onRefresh: () => controller.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card.outlined(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _requestForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ajukan pesanan custom',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Jelaskan motif, warna, dan ukuran agar admin bisa menyiapkan penawaran.',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _description,
                        enabled: !busy,
                        minLines: 3,
                        maxLines: 6,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) => (value?.trim().length ?? 0) < 10
                            ? 'Isi minimal 10 karakter.'
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi pesanan',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lampiran (opsional)',
                        style: theme.textTheme.titleSmall,
                      ),
                      const Text('Maksimal 5 foto · 2 MB per foto'),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () async {
                                final files = await _pickFiles(5);
                                if (mounted && files.isNotEmpty) {
                                  setState(() => _attachments = files);
                                }
                              },
                        icon: const Icon(Icons.attach_file_rounded),
                        label: Text(
                          _attachments.isEmpty
                              ? 'Pilih lampiran'
                              : 'Ganti lampiran',
                        ),
                      ),
                      for (final file in _attachments)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(file.name),
                          trailing: IconButton(
                            tooltip: 'Hapus lampiran',
                            onPressed: busy
                                ? null
                                : () =>
                                      setState(() => _attachments.remove(file)),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_submitError case final message?) FormError(message),
                      AuthButton(
                        text: 'Kirim custom order',
                        onPressed: busy ? null : _create,
                        isLoading: controller.isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Riwayat custom order', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            if (controller.isLoading)
              const LinearProgressIndicator(
                semanticsLabel: 'Memuat custom order',
              )
            else if (controller.orders.isEmpty)
              ContentState(
                icon: Icons.design_services_outlined,
                message: controller.errorMessage ?? 'Belum ada custom order.',
                onRetry: controller.errorMessage == null
                    ? null
                    : () => controller.load(refresh: true),
              ),
            for (final order in controller.orders)
              _requestCard(context, order, busy),
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

  Widget _requestCard(BuildContext context, CustomOrderModel order, bool busy) {
    final theme = Theme.of(context);
    final (icon, tone) = switch (order.status) {
      'quoted' => (Icons.request_quote_outlined, LifecycleTone.active),
      'approved' => (
        Icons.check_circle_outline_rounded,
        LifecycleTone.positive,
      ),
      'cancelled' ||
      'rejected' => (Icons.cancel_outlined, LifecycleTone.negative),
      _ => (Icons.schedule_rounded, LifecycleTone.neutral),
    };
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(order.referenceNumber, style: theme.textTheme.titleSmall),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LifecycleBadge(label: order.statusLabel, icon: icon, tone: tone),
            if (order.estimatedPrice case final price?)
              Text('Penawaran ${formatRupiah(price)}'),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.description),
          if (order.estimatedTime case final time?) Text('Estimasi: $time'),
          if (order.adminNotes case final notes?) Text('Catatan admin: $notes'),
          if (order.attachmentPaths.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (index, path) in order.attachmentPaths.indexed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox.square(
                      dimension: 78,
                      child: CatalogImage(
                        url: productImageUrl(path),
                        label: 'Lampiran ${index + 1}',
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (order.status == 'pending_review' &&
              order.attachmentPaths.length < 5)
            TextButton.icon(
              onPressed: busy ? null : () => _append(order),
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Tambah lampiran'),
            ),
          if (order.status == 'quoted')
            FilledButton(
              onPressed: busy ? null : () => _approve(order),
              child: const Text('Setujui penawaran'),
            ),
          if (order.status == 'pending_review' || order.status == 'quoted')
            TextButton(
              onPressed: busy ? null : () => _cancel(order),
              child: const Text('Batalkan custom order'),
            ),
          if (order.orderId case final id?)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrderDetailView(orderId: id)),
              ),
              child: const Text('Lihat pesanan'),
            ),
        ],
      ),
    );
  }
}

class _QuotationDialog extends StatefulWidget {
  final AddressController addresses;
  final CustomOrderModel order;
  const _QuotationDialog({required this.addresses, required this.order});

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
          if (widget.order.estimatedPrice case final price?)
            Text(
              'Penawaran ${formatRupiah(price)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
