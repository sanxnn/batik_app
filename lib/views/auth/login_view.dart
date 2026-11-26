import 'package:batik_app/widgets/auth/auth_button.dart';
import 'package:batik_app/widgets/auth/auth_layout.dart';
import 'package:batik_app/widgets/auth/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/common/form_error.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String? _submitError;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
    if (controller.isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);

    final success = await controller.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _submitError = controller.errorMessage ?? 'Login gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Masuk ke akun',
          subtitle: 'Gunakan email dan kata sandi yang terdaftar.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_submitError case final message?) FormError(message),
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'mail@example.com',
                  icon: Icons.alternate_email_rounded,
                  enabled: !controller.isLoading,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(value.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Kata sandi',
                  hint: 'Masukkan kata sandi',
                  icon: Icons.lock_outline_rounded,
                  enabled: !controller.isLoading,
                  autofillHints: const [AutofillHints.password],
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    return null;
                  },
                  onSubmitted: (_) {
                    if (!controller.isLoading) {
                      _handleLogin();
                    }
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.isLoading
                        ? null
                        : () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text('Lupa kata sandi?'),
                  ),
                ),
                const SizedBox(height: 22),
                AuthButton(
                  text: 'Masuk',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: controller.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),
                AuthButton(
                  text: 'Buat akun',
                  outlined: true,
                  onPressed: controller.isLoading
                      ? null
                      : () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
