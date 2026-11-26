import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../core/network/payment_launcher.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout/checkout_steps.dart';
import 'order_view.dart';
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
    setState(() => _loading = true);
    final updated = await context.read<OrderController>().refreshDetail(
      widget.orderId,
    );
    if (!mounted) return;
    setState(() {
      _order = updated ?? _order;
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

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final busy =
        _loading ||
        _launchingPayment ||
        context.watch<OrderController>().isSaving;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Perbarui status',
          ),
        ],
      ),
      body: order == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Pesanan tidak ditemukan.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (widget.checkoutPaymentStep) ...[
                  const CheckoutSteps(step: 3),
                  const SizedBox(height: 20),
                  Text(
                    'Pesanan dibuat',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  order.number,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(orderStatusLabel(order.status)),
                if (order.paymentStatus != null)
                  Text('Pembayaran: ${order.paymentStatus}'),
                const Divider(height: 32),
                Text('Produk', style: Theme.of(context).textTheme.titleMedium),
                if (order.items.isEmpty)
                  Text(
                    order.isCustomOrder
                        ? 'Pesanan custom'
                        : 'Detail produk belum tersedia.',
                  ),
                for (final item in order.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name),
                    subtitle: Text('${item.variant} • ${item.quantity} item'),
                    trailing: Text(formatRupiah(item.subtotal)),
                  ),
                const Divider(height: 32),
                if (order.recipient != null)
                  Text('Penerima: ${order.recipient}'),
                if (order.shippingAddress != null) Text(order.shippingAddress!),
                if (order.courier?.isNotEmpty == true)
                  Text('Kurir: ${order.courier}'),
                if (order.trackingNumber?.isNotEmpty == true)
                  Text('Nomor resi: ${order.trackingNumber}'),
                const SizedBox(height: 16),
                _amount('Subtotal', order.subtotal),
                _amount('Diskon', -order.discount),
                _amount('Ongkir', order.shippingCost),
                const Divider(),
                _amount(
                  order.paymentStatus == 'success'
                      ? 'Total dibayar'
                      : 'Total pesanan',
                  order.total,
                  strong: true,
                ),
                const SizedBox(height: 24),
                if (order.status == 'pending_payment' &&
                    order.paymentStatus != 'success') ...[
                  FilledButton(
                    onPressed: busy ? null : _pay,
                    child: Text(
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
                  FilledButton(
                    onPressed: busy ? null : _complete,
                    child: const Text('Konfirmasi pesanan diterima'),
                  ),
                if (order.refund case final refund?)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Status refund'),
                    subtitle: Text(refund.statusLabel),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: busy ? null : () => _openRefund(refundId: refund.id),
                  ),
                if (order.canRequestRefund)
                  OutlinedButton(
                    onPressed: busy ? null : () => _openRefund(),
                    child: const Text('Ajukan refund'),
                  ),
              ],
            ),
    );
  }

  Widget _amount(String label, int amount, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: strong ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          formatRupiah(amount),
          style: TextStyle(
            fontWeight: strong ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
