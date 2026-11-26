import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final int? maxLength;
  final int maxLines;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          maxLength: maxLength,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
