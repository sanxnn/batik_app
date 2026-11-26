import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class AppCountBadge extends StatelessWidget {
  const AppCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      constraints: const BoxConstraints(
        minWidth: AppSpacing.lg,
        minHeight: AppSpacing.lg,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.onInk),
      ),
    );
  }
}
