import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/utils/api_error.dart';
import '../models/order_model.dart';
import '../services/refund_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';

class RefundView extends StatefulWidget {
  final OrderModel order;

  const RefundView({super.key, required this.order});

  @override
  State<RefundView> createState() => _RefundViewState();
}

class _RefundViewState extends State<RefundView> {
  final _reason = TextEditingController();
  final _service = RefundService();
  XFile? _evidence;
  RefundRequestModel? _refund;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.order.refundId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final id = _refund?.id ?? widget.order.refundId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      final refund = await _service.get(id);
      if (mounted) setState(() => _refund = refund);
    } catch (error) {
      _message(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (!{
        'jpg',
        'jpeg',
        'png',
        'webp',
      }.contains(picked.name.split('.').last.toLowerCase())) {
        _message('Gunakan gambar JPEG, PNG, atau WebP.');
        return;
      }
      if (await picked.length() > 5 * 1024 * 1024) {
        _message('Ukuran bukti maksimal 5 MB.');
        return;
      }
      if (mounted) setState(() => _evidence = picked);
    } catch (_) {
      _message('Bukti tidak dapat dipilih.');
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_reason.text.trim().length < 20 || _evidence == null) {
      _message('Tulis alasan minimal 20 karakter dan lampirkan bukti.');
      return;
    }
    setState(() => _busy = true);
    try {
      final refund = await _service.submit(
        orderId: widget.order.id,
        reason: _reason.text,
        evidence: _evidence!,
      );
      if (!mounted) return;
      setState(() => _refund = refund);
      _message('Pengajuan refund berhasil dikirim.', error: false);
    } catch (error) {
      _message(apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String value, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  String _statusLabel(String status) => switch (status) {
    'pending' => 'Menunggu tinjauan admin',
    'approved' => 'Disetujui, menunggu pengembalian dana',
    'processing' => 'Diproses oleh Midtrans',
    'completed' => 'Dana telah dikembalikan',
    'rejected' => 'Ditolak',
    _ => status,
  };

  @override
  Widget build(BuildContext context) {
    final refund = _refund;
    final canApply =
        widget.order.paymentStatus == 'success' &&
        {
          'paid',
          'processing',
          'packing',
          'shipped',
          'completed',
        }.contains(widget.order.status) &&
        ((widget.order.refundId == null && refund == null) ||
            refund?.status == 'rejected');

    return Scaffold(
      appBar: AppAppBar(
        title: 'Refund Pesanan',
        actions: [
          if (widget.order.refundId != null)
            IconButton(
              onPressed: _busy ? null : _refresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Perbarui status',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.number,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Refund penuh: ${formatRupiah(widget.order.total)}'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_busy && refund == null && widget.order.refundId != null)
            const Center(child: CircularProgressIndicator()),
          if (refund != null) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusLabel(refund.status),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Nominal: ${formatRupiah(refund.amount)}'),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Alasan: ${refund.reason}'),
                  if (refund.adminNotes?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Catatan admin: ${refund.adminNotes}'),
                  ],
                  if (refund.manualReference?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Referensi pengembalian: ${refund.manualReference}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (canApply) ...[
            Text(
              'Ajukan refund',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reason,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Alasan refund',
                hintText: 'Jelaskan masalah pada pesanan secara rinci',
                border: OutlineInputBorder(),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _evidence?.name ?? 'Lampirkan foto bukti (maks. 5 MB)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Mengirim...' : 'Kirim pengajuan'),
            ),
          ],
        ],
      ),
    );
  }
}
