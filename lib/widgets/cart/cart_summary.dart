import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.onCheckout,
  });

  final int totalItems;
  final double totalPrice;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$totalItems item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  formatRupiah(totalPrice),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text('Lanjut ke Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
