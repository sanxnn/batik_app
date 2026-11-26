import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/utils/api_error.dart';
import '../core/utils/image_files.dart';
import '../models/order_model.dart';
import '../models/refund_model.dart';
import '../services/refund_service.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/common/form_error.dart';
import '../widgets/orders/lifecycle_badge.dart';

class RefundView extends StatefulWidget {
  final int? orderId;
  final int? refundId;

  const RefundView({super.key, this.orderId, this.refundId})
    : assert((orderId == null) != (refundId == null));

  @override
  State<RefundView> createState() => _RefundViewState();
}

class _RefundViewState extends State<RefundView> {
  final _service = RefundService();
  final _reason = TextEditingController();
  RefundModel? _refund;
  XFile? _image;
  String? _error;
  bool _busy = false;
  bool _picking = false;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final id = widget.refundId;
    if (id != null) _run(() => _service.detail(id));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _run(Future<RefundModel> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final refund = await action();
      if (mounted) setState(() => _refund = refund);
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    try {
      final file = await openFile(acceptedTypeGroups: [commerceImages]);
      if (file == null || !mounted) return;
      final valid = await isSupportedImage(file, 5 * 1024 * 1024);
      if (!mounted) return;
      setState(() {
        _image = valid ? file : null;
        _error = valid
            ? null
            : 'Pilih foto JPEG, PNG, atau WebP maksimal 5 MB.';
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Foto tidak dapat dibuka.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _showEvidence(int id) async {
    final image = _service.evidence(id);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto bukti'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
        content: FutureBuilder(
          future: image,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(apiErrorMessage(snapshot.error!));
            }
            if (!snapshot.hasData) {
              return const Center(
                widthFactor: 1,
                heightFactor: 1,
                child: CircularProgressIndicator(),
              );
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Text('Foto tidak dapat ditampilkan.'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan pengajuan refund?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan pengajuan'),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) await _run(() => _service.cancel(id));
  }

  Future<void> _submit() async {
    if (_busy || _picking || !_form.currentState!.validate()) return;
    final image = _image;
    if (image == null) {
      setState(() => _error = 'Pilih satu foto bukti.');
      return;
    }
    FocusScope.of(context).unfocus();
    await _run(
      () => _service.submit(widget.orderId!, _reason.text.trim(), image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refund = _refund;
    final id = refund?.id ?? widget.refundId;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Ajukan refund' : 'Detail refund'),
        actions: [
          if (id != null)
            IconButton(
              tooltip: 'Perbarui refund',
              onPressed: _busy ? null : () => _run(() => _service.detail(id)),
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (_busy && id != null)
              const LinearProgressIndicator(
                semanticsLabel: 'Memperbarui refund',
              ),
            if (refund != null) ...[
              Card.outlined(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RefundStatusBadge(
                        status: refund.status,
                        label: refund.statusLabel,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatRupiah(refund.amount),
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (refund.orderNumber != null)
                        Text('Pesanan ${refund.orderNumber}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pengajuan', style: theme.textTheme.titleMedium),
              if (refund.reason case final reason?) Text(reason),
              if (refund.adminNotes case final notes?) ...[
                const SizedBox(height: 12),
                Text('Tanggapan admin', style: theme.textTheme.titleMedium),
                Text(notes),
              ],
              if (refund.method case final method?) Text('Metode: $method'),
              if (refund.manualReference case final reference?)
                Text('Referensi: $reference'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _showEvidence(refund.id),
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Lihat foto bukti'),
              ),
              if (refund.status == 'pending')
                TextButton(
                  onPressed: _busy ? null : () => _cancel(refund.id),
                  child: const Text('Batalkan pengajuan'),
                ),
            ] else if (id == null) ...[
              Text(
                'Jelaskan masalah pada pesanan dan lampirkan satu foto bukti.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reason,
                enabled: !_busy,
                maxLength: 2000,
                maxLines: 4,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value?.trim().length ?? 0) < 20
                    ? 'Isi minimal 20 karakter.'
                    : null,
                decoration: const InputDecoration(labelText: 'Alasan refund'),
              ),
              const SizedBox(height: 12),
              Text('Foto bukti', style: theme.textTheme.titleMedium),
              const Text('JPEG, PNG, atau WebP · maksimal 5 MB'),
              const SizedBox(height: 8),
              if (_image case final image?)
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(image.name),
                  trailing: IconButton(
                    tooltip: 'Hapus foto bukti',
                    onPressed: _busy || _picking
                        ? null
                        : () => setState(() => _image = null),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _busy || _picking ? null : _pickImage,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(
                  _image == null ? 'Pilih foto bukti' : 'Ganti foto bukti',
                ),
              ),
              const SizedBox(height: 16),
              if (_error case final message?) FormError(message),
              AuthButton(
                text: 'Kirim pengajuan refund',
                onPressed: _picking ? null : _submit,
                isLoading: _busy,
              ),
            ],
            if (id != null && _error != null) FormError(_error!),
            if (refund == null && id != null && _error != null)
              TextButton(
                onPressed: _busy ? null : () => _run(() => _service.detail(id)),
                child: const Text('Coba lagi'),
              ),
          ],
        ),
      ),
    );
  }
}
