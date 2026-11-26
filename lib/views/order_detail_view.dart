import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../core/network/payment_launcher.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/app_state_view.dart';
import '../widgets/common/status_chip.dart';
import '../widgets/common/app_section.dart';
import 'order_view.dart';
import 'refund_view.dart';

class OrderDetailView extends StatefulWidget {
  final int orderId;
  final OrderModel? initialOrder;
  const OrderDetailView({super.key, required this.orderId, this.initialOrder});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView>
    with WidgetsBindingObserver {
  OrderModel? _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
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
      _loading = false;
    });
  }

  Future<void> _pay() async {
    final controller = context.read<OrderController>();
    final token = _order?.snapToken?.isNotEmpty == true
        ? _order!.snapToken
        : await controller.paymentToken(widget.orderId);
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      _message(
        controller.errorMessage ?? 'Pembayaran belum tersedia. Coba lagi.',
        error: true,
      );
      return;
    }
    try {
      if (!await PaymentLauncher.open(token)) {
        _message('Halaman pembayaran tidak dapat dibuka.', error: true);
      }
    } catch (_) {
      if (mounted) {
        _message('Halaman pembayaran tidak dapat dibuka.', error: true);
      }
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
    if (success) _refresh();
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
    return Scaffold(
      appBar: AppAppBar(
        title: 'Detail Pesanan',
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui status',
          ),
        ],
      ),
      body: order == null
          ? _loading
                ? const Center(child: CircularProgressIndicator())
                : AppStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pesanan tidak ditemukan',
                    message: 'Coba muat ulang detail pesanan.',
                    actionLabel: 'Coba lagi',
                    onAction: _refresh,
                  )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.number,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        StatusChip(
                          label: orderStatusLabel(order.status),
                          tone: orderStatusTone(order.status),
                        ),
                        if (order.paymentStatus != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Pembayaran: ${order.paymentStatus}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const AppSection(title: 'Produk'),
                  AppCard(
                    child: Column(
                      children: [
                        if (order.items.isEmpty)
                          Text(
                            'Detail produk belum tersedia.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        for (final item in order.items)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.variant} • ${item.quantity} item',
                            ),
                            trailing: Text(formatRupiah(item.subtotal)),
                          ),
                      ],
                    ),
                  ),
                  if (order.recipient != null ||
                      order.shippingAddress != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    const AppSection(title: 'Pengiriman'),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.recipient != null)
                            Text(
                              order.recipient!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          if (order.shippingAddress != null)
                            Text(
                              order.shippingAddress!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  const AppSection(title: 'Rincian pembayaran'),
                  AppCard(
                    child: Column(
                      children: [
                        _amount(context, 'Subtotal', order.subtotal),
                        _amount(context, 'Diskon', -order.discount),
                        _amount(context, 'Ongkir', order.shippingCost),
                        const Divider(),
                        _amount(
                          context,
                          'Total dibayar',
                          order.total,
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                  if (order.status == 'pending_payment') ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _loading ||
                                context.watch<OrderController>().isSaving
                            ? null
                            : _pay,
                        child: const Text('Lanjutkan pembayaran'),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _loading || context.watch<OrderController>().isSaving
                          ? null
                          : _cancel,
                      child: const Text('Batalkan pesanan'),
                    ),
                  ],
                  if (order.paymentStatus == 'success' &&
                      {
                        'paid',
                        'processing',
                        'packing',
                        'shipped',
                        'completed',
                      }.contains(order.status)) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RefundView(order: order),
                            ),
                          );
                          _refresh();
                        },
                        child: Text(
                          order.refundId == null
                              ? 'Ajukan refund'
                              : 'Lihat pengajuan refund',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Status pembayaran berasal dari server. Perbarui setelah kembali dari Midtrans.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _amount(
    BuildContext context,
    String label,
    int amount, {
    bool strong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? Theme.of(context).textTheme.bodyLarge
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            formatRupiah(amount),
            style:
                (strong
                        ? Theme.of(context).textTheme.bodyLarge
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
