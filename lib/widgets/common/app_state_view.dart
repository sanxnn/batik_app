import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary, size: 36),
              ),
              const SizedBox(height: AppTheme.spaceLarge),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spaceSmall),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: AppTheme.spaceLarge),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
