import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

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
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

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
    this.autofillHints,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      maxLength: maxLength,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffixIcon,
        counterText: '',
        errorMaxLines: 3,
      ),
    );
  }
}
