import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

enum AppStatusTone { success, info, warning, danger }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      AppStatusTone.success => (AppColors.success, AppColors.successSoft),
      AppStatusTone.info => (AppColors.info, AppColors.infoSoft),
      AppStatusTone.warning => (AppColors.warning, AppColors.yellowSoft),
      AppStatusTone.danger => (AppColors.danger, AppColors.dangerSoft),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}
