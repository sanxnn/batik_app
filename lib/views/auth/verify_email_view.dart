import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/common/form_error.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;

  const VerifyEmailView({super.key, required this.email});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final controller = context.read<AuthController>();
    if (controller.isLoading) return;
    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);

    final success = await controller.verifyEmail(
      widget.email,
      _otpCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email berhasil diverifikasi. Silakan login.'),
          backgroundColor: AppTheme.success,
        ),
      );
      // Hapus semua halaman sebelumnya dan arahkan ke login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      setState(
        () => _submitError = controller.errorMessage ?? 'Verifikasi OTP gagal.',
      );
    }
  }

  Future<void> _handleResend() async {
    final controller = context.read<AuthController>();
    if (_isSubmitting || controller.isLoading) return;
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    final success = await controller.resendOtp(widget.email);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!success) {
      setState(
        () => _submitError =
            controller.errorMessage ?? 'Gagal mengirim ulang OTP.',
      );
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Kode OTP baru dikirim.')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Verifikasi email',
          subtitle: 'Satu langkah lagi untuk mengaktifkan akunmu.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_submitError case final message?) FormError(message),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        size: 48,
                        color: AppTheme.accentInk,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kode OTP dikirim ke',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
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
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onSubmitted: (_) => _handleVerify(),
                  validator: (value) {
                    final otp = value?.trim() ?? '';
                    if (otp.length != 6) {
                      return 'OTP harus terdiri dari 6 digit';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
                      return 'OTP hanya boleh berisi angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AuthButton(
                  text: 'Verifikasi Email',
                  icon: Icons.verified_outlined,
                  isLoading: _isSubmitting || controller.isLoading,
                  onPressed: _handleVerify,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: (_isSubmitting || controller.isLoading)
                        ? null
                        : _handleResend,
                    child: const Text('Kirim Ulang OTP'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: (_isSubmitting || controller.isLoading)
                        ? null
                        : () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
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
