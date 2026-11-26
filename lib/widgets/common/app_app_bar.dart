import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      actions: actions,
      leadingWidth: AppSpacing.touchTarget + AppSpacing.xs,
    );
  }
}
