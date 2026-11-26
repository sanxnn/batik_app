import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../theme/app_spacing.dart';
import 'app_card.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.statusLabel,
    required this.statusTone,
    required this.onTap,
  });

  final OrderModel order;
  final String statusLabel;
  final AppStatusTone statusTone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = order.createdAt?.toLocal();
    return InkWell(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.number,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            if (date != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            StatusChip(label: statusLabel, tone: statusTone),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formatRupiah(order.total),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
