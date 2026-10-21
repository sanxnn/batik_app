import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/auth_layout.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';

class ResetPasswordOtpView extends StatefulWidget {
  final String email;

  const ResetPasswordOtpView({super.key, required this.email});

  @override
  State<ResetPasswordOtpView> createState() => _ResetPasswordOtpViewState();
}

class _ResetPasswordOtpViewState extends State<ResetPasswordOtpView> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final controller = context.read<AuthController>();

    final resetToken = await controller.verifyPasswordResetOtp(widget.email, _otpCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (resetToken != null) {
      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: {
          'email': widget.email,
          'resetToken': resetToken,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Verifikasi OTP gagal.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    
    final controller = context.read<AuthController>();
    final success = await controller.forgotPassword(widget.email);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'OTP baru berhasil dikirim.' : (controller.errorMessage ?? 'Gagal mengirim ulang OTP.')),
        backgroundColor: success ? AppTheme.success : AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Verifikasi OTP 🔐',
          subtitle: 'Verifikasi kode terlebih dahulu sebelum membuat password baru.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_reset_rounded, size: 48, color: AppTheme.primaryDark),
                      const SizedBox(height: 12),
                      const Text('Kode OTP dikirim ke', textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _otpCtrl,
                  label: 'Kode OTP',
                  hint: 'Masukkan 6 digit kode',
                  icon: Icons.password_rounded,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  enabled: !_isSubmitting && !controller.isLoading,
                  maxLength: 6,
                  onSubmitted: (_) => _handleVerify(),
                  validator: (value) {
                    final otp = value?.trim() ?? '';
                    if (otp.length != 6) return 'OTP harus terdiri dari 6 digit';
                    if (!RegExp(r'^\d{6}$').hasMatch(otp)) return 'OTP hanya boleh berisi angka';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthButton(
                  text: 'Verifikasi & Lanjut',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isSubmitting || controller.isLoading,
                  onPressed: _handleVerify,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: (_isSubmitting || controller.isLoading) ? null : _handleResend,
                    child: const Text('Kirim Ulang OTP'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: (_isSubmitting || controller.isLoading) ? null : () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
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