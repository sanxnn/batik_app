import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = AppSpacing.md});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
