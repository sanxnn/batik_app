import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    super.key,
    required this.status,
    this.paymentSucceeded = false,
  });

  final String status;
  final bool paymentSucceeded;

  static const _stages = [
    'Menunggu bayar',
    'Dibayar',
    'Diproses',
    'Dikirim',
    'Selesai',
  ];
  static const _icons = [
    Icons.schedule_rounded,
    Icons.payments_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final current = switch (status) {
      'pending_payment' => 0,
      'paid' => 1,
      'processing' || 'packing' => 2,
      'shipped' => 3,
      'completed' => 4,
      _ => null,
    };
    final theme = Theme.of(context);
    if (current == null) {
      return Text(
        status == 'cancelled'
            ? (paymentSucceeded
                  ? 'Pesanan dibatalkan. Pembayaran tercatat berhasil.'
                  : 'Pesanan dibatalkan dan pengiriman dihentikan.')
            : 'Perjalanan pesanan belum tersedia.',
        style: theme.textTheme.bodyMedium,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _stages.length; index++)
          _step(theme, index, current),
      ],
    );
  }

  Widget _step(ThemeData theme, int index, int current) {
    final colors = theme.colorScheme;
    final done = index < current || (index == current && status == 'completed');
    final active = index == current;
    final state = done
        ? 'Selesai'
        : active
        ? 'Saat ini'
        : 'Belum tercapai';
    return Semantics(
      label: '${_stages[index]}, $state',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: active || done
                    ? colors.secondaryContainer
                    : colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check_rounded : _icons[index],
                size: 16,
                color: active || done
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _stages[index],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
            if (active && !done)
              Text('Saat ini', style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
