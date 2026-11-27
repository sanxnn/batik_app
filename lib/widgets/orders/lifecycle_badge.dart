import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum LifecycleTone { active, neutral, positive, negative }

class LifecycleBadge extends StatelessWidget {
  const LifecycleBadge({
    super.key,
    required this.label,
    required this.icon,
    this.tone = LifecycleTone.active,
  });

  final String label;
  final IconData icon;
  final LifecycleTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (background, foreground) = switch (tone) {
      LifecycleTone.active => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
      LifecycleTone.neutral => (
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
      ),
      LifecycleTone.positive => (AppTheme.successContainer, AppTheme.success),
      LifecycleTone.negative => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, tone) = switch (status) {
      'pending_payment' => (
        'Menunggu pembayaran',
        Icons.schedule_rounded,
        LifecycleTone.active,
      ),
      'paid' => (
        'Sudah dibayar',
        Icons.payments_outlined,
        LifecycleTone.positive,
      ),
      'processing' => (
        'Diproses',
        Icons.inventory_2_outlined,
        LifecycleTone.active,
      ),
      'packing' => (
        'Dikemas',
        Icons.inventory_2_outlined,
        LifecycleTone.active,
      ),
      'shipped' => (
        'Dikirim',
        Icons.local_shipping_outlined,
        LifecycleTone.active,
      ),
      'completed' => (
        'Selesai',
        Icons.check_circle_outline_rounded,
        LifecycleTone.positive,
      ),
      'cancelled' => (
        'Dibatalkan',
        Icons.cancel_outlined,
        LifecycleTone.negative,
      ),
      _ => (
        'Status belum tersedia',
        Icons.info_outline_rounded,
        LifecycleTone.neutral,
      ),
    };
    return LifecycleBadge(label: label, icon: icon, tone: tone);
  }
}

class RefundStatusBadge extends StatelessWidget {
  const RefundStatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) => LifecycleBadge(
    label: label,
    icon: switch (status) {
      'completed' => Icons.check_circle_outline_rounded,
      'cancelled' || 'rejected' => Icons.cancel_outlined,
      _ => Icons.schedule_rounded,
    },
    tone: switch (status) {
      'completed' => LifecycleTone.positive,
      'cancelled' || 'rejected' => LifecycleTone.negative,
      _ => LifecycleTone.active,
    },
  );
}
