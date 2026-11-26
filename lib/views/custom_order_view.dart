import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/address_controller.dart';
import '../controllers/custom_order_controller.dart';
import '../models/order_model.dart';
import '../core/network/image_url.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_state_view.dart';
import '../widgets/common/status_chip.dart';
import '../widgets/common/app_section.dart';
import '../widgets/common/app_network_image.dart';
import 'order_detail_view.dart';

class CustomOrderView extends StatefulWidget {
  const CustomOrderView({super.key});

  @override
  State<CustomOrderView> createState() => _CustomOrderViewState();
}

class _CustomOrderViewState extends State<CustomOrderView> {
  final _description = TextEditingController();
  List<XFile> _attachments = [];

  Future<List<XFile>?> _pickImages({int existingCount = 0}) async {
    try {
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isEmpty) return null;
      if (picked.length + existingCount > 5) {
        _message('Maksimal 5 gambar per custom order.', error: true);
        return null;
      }
      for (final file in picked) {
        final extension = file.name.split('.').last.toLowerCase();
        if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
          _message('Gunakan gambar JPEG, PNG, atau WebP.', error: true);
          return null;
        }
        if (await file.length() > 2 * 1024 * 1024) {
          _message('Setiap gambar maksimal 2 MB.', error: true);
          return null;
        }
      }
      return picked;
    } catch (_) {
      if (mounted) _message('Gagal memilih gambar.', error: true);
      return null;
    }
  }

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

  Future<String?> _approvalNotes() async {
    final notes = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Setujui quotation'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Catatan untuk pesanan (opsional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, notes.text.trim()),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    notes.dispose();
    return value;
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

  Future<void> _addAttachments(int id, int existingCount) async {
    final picked = await _pickImages(existingCount: existingCount);
    if (picked == null || !mounted) return;
    final success = await context.read<CustomOrderController>().addAttachments(
      id,
      picked,
    );
    if (!mounted) return;
    _message(
      success
          ? 'Gambar berhasil ditambahkan.'
          : context.read<CustomOrderController>().errorMessage ??
                'Gagal menambahkan gambar.',
      error: !success,
    );
  }

  Future<void> _approve(int id) async {
    final addresses = context.read<AddressController>();
    if (addresses.addresses.isEmpty) {
      _message('Tambahkan alamat sebelum menyetujui quotation.', error: true);
      return;
    }
    final addressId =
        addresses.primaryAddress?.id ?? addresses.addresses.first.id;
    final notes = await _approvalNotes();
    if (!mounted || notes == null) return;
    final orderId = await context.read<CustomOrderController>().approve(
      id,
      addressId: addressId,
      notes: notes,
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

  Future<void> _cancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan custom order?'),
        content: const Text(
          'Permintaan yang dibatalkan tidak dapat dilanjutkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<CustomOrderController>().cancel(id);
    if (!mounted) return;
    _message(
      success
          ? 'Custom order dibatalkan.'
          : context.read<CustomOrderController>().errorMessage ??
                'Custom order gagal dibatalkan.',
      error: !success,
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
      appBar: const AppAppBar(title: 'Custom Order'),
      body: RefreshIndicator(
        onRefresh: () => controller.load(refresh: true),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(
              'Karya sesuai keinginanmu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Jelaskan motif, warna, ukuran, dan kebutuhan lainnya. Admin akan meninjau dan mengirim quotation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _description,
                    minLines: 5,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi pesanan',
                      hintText: 'Jelaskan kebutuhan pesanan Anda',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: controller.isSaving
                        ? null
                        : () async {
                            final picked = await _pickImages();
                            if (picked != null && mounted) {
                              setState(() => _attachments = picked);
                            }
                          },
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      _attachments.isEmpty
                          ? 'Pilih gambar (opsional)'
                          : '${_attachments.length} gambar dipilih',
                    ),
                  ),
                  if (_attachments.isNotEmpty)
                    Text(_attachments.map((file) => file.name).join(', ')),
                  ElevatedButton(
                    onPressed: controller.isSaving ? null : _create,
                    child: Text(
                      controller.isSaving
                          ? 'Mengirim...'
                          : 'Kirim custom order',
                    ),
                  ),
                ],
              ),
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                controller.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const AppSection(title: 'Riwayat permintaan'),
            if (controller.isLoading && controller.orders.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (!controller.isLoading && controller.orders.isEmpty)
              const AppStateView(
                icon: Icons.design_services_outlined,
                title: 'Belum ada permintaan',
                message: 'Permintaan custom order akan tampil di sini.',
              ),
            for (final order in controller.orders) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.referenceNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    StatusChip(
                      label: order.status,
                      tone: order.status == 'cancelled'
                          ? AppStatusTone.danger
                          : order.status == 'approved'
                          ? AppStatusTone.success
                          : AppStatusTone.warning,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      order.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (order.attachments.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: order.attachments.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.xs),
                          itemBuilder: (_, index) => AppNetworkImage(
                            url: productImageUrl(
                              order.attachments[index].filePath,
                            ),
                            width: 72,
                            height: 72,
                          ),
                        ),
                      ),
                    ],
                    if (order.estimatedPrice != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Quotation: ${formatRupiah(order.estimatedPrice!)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                    if (order.status == 'quoted' ||
                        order.status == 'pending_review') ...[
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: [
                          if (order.status == 'pending_review' &&
                              order.attachments.length < 5)
                            TextButton.icon(
                              onPressed: controller.isSaving
                                  ? null
                                  : () => _addAttachments(
                                      order.id,
                                      order.attachments.length,
                                    ),
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                              ),
                              label: const Text('Tambah gambar'),
                            ),
                          if (order.status == 'quoted')
                            TextButton(
                              onPressed: controller.isSaving
                                  ? null
                                  : () => _approve(order.id),
                              child: const Text('Setujui'),
                            ),
                          TextButton(
                            onPressed: controller.isSaving
                                ? null
                                : () => _cancel(order.id),
                            child: const Text('Batalkan'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
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
