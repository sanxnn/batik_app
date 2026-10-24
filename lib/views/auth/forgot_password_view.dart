import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleForgot() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Gagal mengirim OTP.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Lupa Password? 🔐',
          subtitle:
              'Tenang, kami bantu kamu kembali ke akun Batik Rubung Kuning.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informasi reset password
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.mark_email_unread_outlined,
                        color: AppTheme.primaryDark,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset password dengan OTP',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Masukkan email yang terdaftar. Kami akan '
                              'mengirimkan kode OTP untuk mengatur ulang '
                              'password akunmu.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                AuthTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'nama@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
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
                  text: 'Kirim Kode OTP',
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

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Pastikan email yang kamu masukkan masih aktif.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textHint),
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
