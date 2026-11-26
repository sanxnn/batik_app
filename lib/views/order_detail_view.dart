import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../core/network/payment_launcher.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout/checkout_steps.dart';
import '../widgets/common/content_state.dart';
import '../widgets/common/form_error.dart';
import '../widgets/orders/lifecycle_badge.dart';
import '../widgets/orders/order_timeline.dart';
import 'refund_view.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  final OrderModel? initialOrder;
  final bool checkoutPaymentStep;
  final String? initialSnapToken;
  const OrderDetailView({
    super.key,
    required this.orderId,
    this.initialOrder,
    this.checkoutPaymentStep = false,
    this.initialSnapToken,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView>
    with WidgetsBindingObserver {
  OrderModel? _order;
  bool _loading = false;
  bool _launchingPayment = false;
  String? _paymentToken;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _paymentToken = widget.initialSnapToken;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted || _loading) return;
    setState(() {
      _loading = true;
      _refreshError = null;
    });
    final controller = context.read<OrderController>();
    final updated = await controller.refreshDetail(widget.orderId);
    if (!mounted) return;
    setState(() {
      _order = updated ?? _order;
      _refreshError = updated == null ? controller.errorMessage : null;
      if (updated != null && updated.status != 'pending_payment') {
        _paymentToken = null;
      }
      _loading = false;
    });
  }

  Future<void> _pay() async {
    if (_launchingPayment) return;
    final controller = context.read<OrderController>();
    setState(() => _launchingPayment = true);
    try {
      final serverToken = _order?.snapToken;
      final known = serverToken?.isNotEmpty == true
          ? serverToken
          : _paymentToken;
      final token = known?.isNotEmpty == true
          ? known
          : await controller.paymentToken(widget.orderId);
      if (!mounted) return;
      if (token == null || token.isEmpty) {
        _message(
          controller.errorMessage ?? 'Pembayaran belum tersedia. Coba lagi.',
          error: true,
        );
        return;
      }
      _paymentToken = token;
      if (!await PaymentLauncher.open(token) && mounted) {
        _message(
          'Halaman pembayaran tidak dapat dibuka. Coba lagi.',
          error: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _message(
          'Halaman pembayaran tidak dapat dibuka. Coba lagi.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _launchingPayment = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: const Text(
          'Pesanan yang dibatalkan tidak dapat dibayar kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan pesanan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final controller = context.read<OrderController>();
    final success = await controller.cancel(widget.orderId);
    if (!mounted) return;
    _message(
      success
          ? 'Pesanan dibatalkan.'
          : controller.errorMessage ?? 'Gagal membatalkan.',
      error: !success,
    );
    _refresh();
  }

  Future<void> _complete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi penerimaan'),
        content: const Text('Konfirmasi setelah paket sudah Anda terima.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pesanan diterima'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final controller = context.read<OrderController>();
    final updated = await controller.complete(widget.orderId);
    if (!mounted) return;
    _message(
      updated != null
          ? 'Penerimaan pesanan dikonfirmasi.'
          : controller.errorMessage ?? 'Gagal mengonfirmasi penerimaan.',
      error: updated == null,
    );
    if (updated != null) setState(() => _order = updated);
    await _refresh();
  }

  Future<void> _openRefund({int? refundId}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => refundId == null
            ? RefundView(orderId: widget.orderId)
            : RefundView(refundId: refundId),
      ),
    );
    if (mounted) await _refresh();
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppTheme.error : AppTheme.success,
      ),
    );
  }

  Future<void> _copyTrackingNumber(String number) async {
    try {
      await Clipboard.setData(ClipboardData(text: number));
      if (mounted) _message('Nomor resi disalin.');
    } catch (_) {
      if (mounted) _message('Nomor resi tidak dapat disalin.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final busy =
        _loading ||
        _launchingPayment ||
        context.watch<OrderController>().isSaving;
    final theme = Theme.of(context);
    final payment = switch (order?.paymentStatus) {
      'success' => 'Berhasil',
      'pending' => 'Menunggu pembayaran',
      'failed' => 'Gagal',
      'expire' => 'Kedaluwarsa',
      _ => null,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail pesanan'),
        actions: [
          IconButton(
            onPressed: busy ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui status',
          ),
        ],
      ),
      body: order == null
          ? _loading
                ? const ContentLoading(label: 'Memuat detail pesanan')
                : ContentState(
                    icon: Icons.receipt_long_outlined,
                    message: _refreshError ?? 'Pesanan belum tersedia.',
                    onRetry: _refresh,
                  )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (widget.checkoutPaymentStep) ...[
                  const CheckoutSteps(step: 3),
                  const SizedBox(height: 16),
                ],
                if (_loading)
                  const LinearProgressIndicator(
                    semanticsLabel: 'Memperbarui pesanan',
                  ),
                if (_refreshError case final message?) FormError(message),
                _section(
                  context,
                  widget.checkoutPaymentStep ? 'Pesanan dibuat' : order.number,
                  [
                    if (widget.checkoutPaymentStep) Text(order.number),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OrderStatusBadge(status: order.status),
                    ),
                    if (payment != null) Text('Pembayaran: $payment'),
                    if (order.status == 'pending_payment' &&
                        order.paymentStatus != 'success') ...[
                      _amount('Total pesanan', order.total, strong: true),
                      FilledButton.icon(
                        onPressed: busy ? null : _pay,
                        icon: const Icon(Icons.payments_outlined),
                        label: Text(
                          _launchingPayment
                              ? 'Membuka pembayaran…'
                              : 'Lanjutkan pembayaran',
                        ),
                      ),
                      TextButton(
                        onPressed: busy ? null : _cancel,
                        child: const Text('Batalkan pesanan'),
                      ),
                    ],
                    if (order.canComplete)
                      FilledButton.icon(
                        onPressed: busy ? null : _complete,
                        icon: const Icon(Icons.done_rounded),
                        label: const Text('Konfirmasi pesanan diterima'),
                      ),
                  ],
                ),
                _section(context, 'Perjalanan pesanan', [
                  OrderTimeline(
                    status: order.status,
                    paymentSucceeded: order.paymentStatus == 'success',
                  ),
                ]),
                if (order.shippingAddress != null ||
                    order.recipient != null ||
                    order.courier?.isNotEmpty == true ||
                    order.trackingNumber?.isNotEmpty == true)
                  _section(context, 'Pengiriman', [
                    if (order.recipient != null)
                      Text(order.recipient!, style: theme.textTheme.titleSmall),
                    if (order.shippingAddress != null)
                      Text(order.shippingAddress!),
                    if (order.courier?.isNotEmpty == true)
                      Text('Kurir: ${order.courier}'),
                    if (order.trackingNumber case final number?
                        when number.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Nomor resi\n$number',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Salin nomor resi',
                            onPressed: () => _copyTrackingNumber(number),
                            icon: const Icon(Icons.copy_rounded),
                          ),
                        ],
                      ),
                  ]),
                _section(context, 'Ringkasan biaya', [
                  if (order.items.isEmpty)
                    Text(
                      order.isCustomOrder
                          ? 'Pesanan custom'
                          : 'Detail produk belum tersedia.',
                    ),
                  for (final item in order.items)
                    _amount(
                      '${item.name}\n${item.variant} × ${item.quantity}',
                      item.subtotal,
                    ),
                  const Divider(),
                  _amount('Subtotal', order.subtotal),
                  if (order.discount != 0) _amount('Diskon', -order.discount),
                  _amount('Ongkir', order.shippingCost),
                  _amount(
                    order.paymentStatus == 'success'
                        ? 'Total dibayar'
                        : 'Total pesanan',
                    order.total,
                    strong: true,
                  ),
                ]),
                if (order.refund != null || order.canRequestRefund)
                  _section(context, 'Refund', [
                    if (order.refund case final refund?) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RefundStatusBadge(
                          status: refund.status,
                          label: refund.statusLabel,
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => _openRefund(refundId: refund.id),
                        child: const Text('Lihat detail refund'),
                      ),
                    ],
                    if (order.canRequestRefund)
                      OutlinedButton(
                        onPressed: busy ? null : () => _openRefund(),
                        child: const Text('Ajukan refund'),
                      ),
                  ]),
              ],
            ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) =>
      Card.outlined(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              for (final child in children) ...[
                const SizedBox(height: 8),
                child,
              ],
            ],
          ),
        ),
      );

  Widget _amount(String label, int amount, {bool strong = false}) =>
      DefaultTextStyle.merge(
        style: strong ? const TextStyle(fontWeight: FontWeight.w700) : null,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 4,
          children: [Text(label), Text(formatRupiah(amount))],
        ),
      );
}
