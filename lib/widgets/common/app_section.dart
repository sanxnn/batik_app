import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppSection extends StatelessWidget {
  const AppSection({super.key, required this.title, this.child, this.trailing});

  final String title;
  final Widget? child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppTheme.spaceMedium),
        ?child,
      ],
    );
  }
}
