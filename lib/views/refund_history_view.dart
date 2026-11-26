import 'package:flutter/material.dart';

import '../core/utils/api_error.dart';
import '../models/order_model.dart';
import '../models/refund_model.dart';
import '../services/refund_service.dart';
import '../widgets/common/content_state.dart';
import '../widgets/orders/lifecycle_badge.dart';
import 'refund_view.dart';

class RefundHistoryView extends StatefulWidget {
  const RefundHistoryView({super.key});

  @override
  State<RefundHistoryView> createState() => _RefundHistoryViewState();
}

class _RefundHistoryViewState extends State<RefundHistoryView> {
  final _service = RefundService();
  List<RefundModel> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loading) return;
    final page = refresh ? 1 : _page + 1;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.list(page);
      if (!mounted) return;
      setState(() {
        _items = refresh ? result.items : [..._items, ...result.items];
        _page = page;
        _hasMore = result.hasMore;
      });
    } catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat refund')),
    body: RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (_loading)
            const LinearProgressIndicator(semanticsLabel: 'Memuat refund'),
          if (_error != null)
            ContentState(
              icon: Icons.sync_problem_rounded,
              message: _error!,
              onRetry: () => _load(refresh: _page == 0 || !_hasMore),
            ),
          if (!_loading && _error == null && _items.isEmpty)
            const ContentState(
              icon: Icons.receipt_long_outlined,
              message: 'Belum ada pengajuan refund.',
            ),
          for (final refund in _items)
            Card.outlined(
              child: ListTile(
                title: Text(refund.orderNumber ?? 'Refund #${refund.id}'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RefundStatusBadge(
                        status: refund.status,
                        label: refund.statusLabel,
                      ),
                      const SizedBox(height: 6),
                      Text(formatRupiah(refund.amount)),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RefundView(refundId: refund.id),
                    ),
                  );
                  if (mounted) await _load(refresh: true);
                },
              ),
            ),
          if (_hasMore && !_loading && _error == null && _items.isNotEmpty)
            TextButton(
              onPressed: () => _load(refresh: _page == 0),
              child: const Text('Muat lainnya'),
            ),
        ],
      ),
    ),
  );
}
