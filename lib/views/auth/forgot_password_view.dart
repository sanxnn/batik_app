import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/common/form_error.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _submitError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleForgot() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
    if (controller.isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);
    final email = _emailCtrl.text.trim();

    final success = await controller.forgotPassword(email);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/reset-password-otp',
        arguments: email,
      );
    } else {
      setState(
        () => _submitError = controller.errorMessage ?? 'Gagal mengirim OTP.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Lupa kata sandi?',
          subtitle: 'Masukkan email yang terdaftar untuk menerima kode reset.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_submitError case final message?) FormError(message),
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'nama@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.done,
                  enabled: !controller.isLoading,
                  onSubmitted: (_) {
                    if (!controller.isLoading) _handleForgot();
                  },
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Email wajib diisi';
                    }

                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Format email tidak valid';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                AuthButton(
                  text: 'Kirim kode OTP',
                  icon: Icons.send_rounded,
                  isLoading: controller.isLoading,
                  onPressed: _handleForgot,
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton.icon(
                    onPressed: controller.isLoading
                        ? null
                        : () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Kembali ke halaman login'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
