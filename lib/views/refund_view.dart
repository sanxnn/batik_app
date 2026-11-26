import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/utils/api_error.dart';
import '../core/utils/image_files.dart';
import '../models/order_model.dart';
import '../models/refund_model.dart';
import '../services/refund_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final refund = _refund;
    final id = refund?.id ?? widget.refundId;
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Ajukan refund' : 'Detail refund'),
        actions: [
          if (id != null)
            IconButton(
              tooltip: 'Perbarui refund',
              onPressed: _busy ? null : () => _run(() => _service.detail(id)),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (refund != null) ...[
            if (refund.orderNumber != null) Text(refund.orderNumber!),
            Text(
              refund.statusLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Nominal refund: ${formatRupiah(refund.amount)}'),
            if (refund.reason != null) Text('Alasan: ${refund.reason}'),
            if (refund.adminNotes != null)
              Text('Catatan admin: ${refund.adminNotes}'),
            if (refund.method != null) Text('Metode: ${refund.method}'),
            if (refund.manualReference != null)
              Text('Referensi: ${refund.manualReference}'),
            OutlinedButton(
              onPressed: () => _showEvidence(refund.id),
              child: const Text('Lihat foto bukti'),
            ),
            if (refund.status == 'pending')
              TextButton(
                onPressed: _busy ? null : () => _cancel(refund.id),
                child: const Text('Batalkan pengajuan'),
              ),
          ] else if (id == null) ...[
            TextField(
              controller: _reason,
              enabled: !_busy,
              maxLength: 2000,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Alasan refund',
                helperText: 'Minimal 20 karakter',
              ),
            ),
            OutlinedButton(
              onPressed: _busy || _picking ? null : _pickImage,
              child: Text(_image?.name ?? 'Pilih foto bukti (maks. 5 MB)'),
            ),
            FilledButton(
              onPressed: _busy || _picking
                  ? null
                  : () {
                      final reason = _reason.text.trim();
                      final image = _image;
                      if (reason.length < 20 || image == null) {
                        setState(
                          () => _error = 'Isi alasan minimal 20 karakter dan pilih foto bukti.',
                        );
                        return;
                      }
                      _run(
                        () => _service.submit(widget.orderId!, reason, image),
                      );
                    },
              child: const Text('Kirim pengajuan refund'),
            ),
          ],
        ],
      ),
    );
  }
}
