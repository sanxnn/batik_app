import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/common/form_error.dart';
import '../../widgets/auth/birth_date_field.dart';
import '../../widgets/auth/auth_layout.dart';
import '../../widgets/auth/auth_text_field.dart';
import '../../widgets/auth/auth_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  String? _submitError;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _gender = 'Male';
  DateTime? _birthDate;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<AuthController>();
    if (controller.isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);

    final success = await controller.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      passwordConfirmation: _confirmPasswordCtrl.text,
      gender: _gender,
      birthDate: _birthDate!,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/verify-email',
        arguments: _emailCtrl.text.trim(),
      );
    } else {
      setState(
        () => _submitError = controller.errorMessage ?? 'Registrasi gagal',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().isLoading;
    return AuthLayout(
      title: 'Buat akun',
      subtitle: 'Lengkapi data untuk berbelanja dan melacak pesanan.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_submitError case final message?) FormError(message),
            AuthTextField(
              controller: _nameCtrl,
              label: 'Nama lengkap',
              hint: 'Sesuai identitas',
              enabled: !busy,
              autofillHints: const [AutofillHints.name],
              validator: (value) =>
                  value?.trim().isNotEmpty == true ? null : 'Nama wajib diisi',
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'nama@email.com',
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: (value) =>
                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(value?.trim() ?? '')
                  ? null
                  : 'Masukkan email yang valid',
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _phoneCtrl,
              label: 'Nomor telepon (opsional)',
              hint: '081234567890',
              enabled: !busy,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Jenis kelamin'),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'Female', child: Text('Perempuan')),
              ],
              onChanged: busy
                  ? null
                  : (value) {
                      if (value != null) setState(() => _gender = value);
                    },
            ),
            const SizedBox(height: 16),
            BirthDateField(
              value: _birthDate,
              enabled: !busy,
              onChanged: (value) => setState(() => _birthDate = value),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordCtrl,
              label: 'Kata sandi',
              hint: 'Minimal 8 karakter',
              enabled: !busy,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              suffixIcon: _visibility(
                _obscurePassword,
                () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) => (value?.length ?? 0) < 8
                  ? 'Gunakan minimal 8 karakter'
                  : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordCtrl,
              label: 'Konfirmasi kata sandi',
              hint: 'Ulangi kata sandi',
              enabled: !busy,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegister(),
              suffixIcon: _visibility(
                _obscureConfirmPassword,
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: (value) =>
                  value == _passwordCtrl.text ? null : 'Kata sandi tidak cocok',
            ),
            const SizedBox(height: 20),
            AuthButton(
              text: 'Buat akun',
              onPressed: _handleRegister,
              isLoading: busy,
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Sudah punya akun? Masuk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibility(bool hidden, VoidCallback toggle) => IconButton(
    tooltip: hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
    onPressed: toggle,
    icon: Icon(
      hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    ),
  );
}
