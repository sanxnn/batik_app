import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Kategori $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: AppSpacing.categoryWidth,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: AppSpacing.categoryIcon,
                height: AppSpacing.categoryIcon,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.brandYellow
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: selected ? AppColors.brandYellow : AppColors.border,
                  ),
                ),
                child: Icon(icon, color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.ink : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
