import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class AppMenuTile extends StatelessWidget {
  const AppMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: AppSpacing.xs,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
