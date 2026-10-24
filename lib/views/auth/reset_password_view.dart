import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  String? _email;
  String? _resetToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _resetToken = args['resetToken'] as String?;
    }

    if (_email == null || _resetToken == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/forgot-password');
      });
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    if (_email == null || _resetToken == null) return;

    setState(() => _isSubmitting = true);
    final controller = context.read<AuthController>();

    final success = await controller.resetPassword(
      email: _email!,
      resetToken: _resetToken!,
      password: _passwordCtrl.text,
      passwordConfirmation: _confirmPasswordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diubah. Silakan login kembali.'),
          backgroundColor: AppTheme.success,
        ),
      );
      // Hapus semua halaman dan arahkan ke login
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Gagal mengubah password.'),
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
          title: 'Buat Password Baru 🔑',
          subtitle: 'Pastikan password baru Anda mudah diingat namun tetap aman.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Password Baru',
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline,
                  obscureText: true, // Pastikan widget Anda mendukung properti ini
                  enabled: !_isSubmitting && !controller.isLoading,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmPasswordCtrl,
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password baru',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  enabled: !_isSubmitting && !controller.isLoading,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleReset(),
                  validator: (value) {
                    if (value != _passwordCtrl.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AuthButton(
                  text: 'Simpan Password',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSubmitting || controller.isLoading,
                  onPressed: _handleReset,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: (_isSubmitting || controller.isLoading) ? null : () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Batal'),
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