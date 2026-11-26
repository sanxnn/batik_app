import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? SizedBox(
            width: AppSpacing.lg,
            height: AppSpacing.lg,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? AppColors.ink : AppColors.onInk,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: Text(text, textAlign: TextAlign.center)),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(icon),
              ],
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.touchTarget + AppSpacing.xs,
      child: outlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: content,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: content,
            ),
    );
  }
}
