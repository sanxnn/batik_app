import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../common/batik_accent.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBranding = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBranding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBranding) ...[
                        const _AuthBranding(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                      Text(
                        title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBranding extends StatelessWidget {
  const _AuthBranding();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandYellow, AppColors.brandYellowDark],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: BatikAccent(opacity: 0.06)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Batik Rubung Kuning',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: AppColors.onBrandYellow),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Karya batik dari Jember',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.onBrandYellow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
