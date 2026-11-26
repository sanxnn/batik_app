import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/birth_date_field.dart';
import '../widgets/common/form_error.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late String _gender;
  DateTime? _birthDate;
  String? _submitError;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.read<AuthController>().user;
      if (user != null) {
        _nameCtrl.text = user.name;
        _emailCtrl.text = user.email;
        _phoneCtrl.text = user.phone ?? '';
        _gender = user.gender == 'Female' ? 'Female' : 'Male';
        _birthDate = user.birthDate;
        _isInitialized = true;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
    if (controller.isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitError = null);
    final success = await controller.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      setState(
        () => _submitError =
            controller.errorMessage ?? 'Profil gagal diperbarui.',
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui.')),
    );

    if (controller.user?.isEmailVerified == false) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/verify-email',
        (_) => false,
        arguments: controller.user!.email,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isInitialized)
              const Text('Profil belum tersedia.')
            else ...[
              if (_submitError case final message?) FormError(message),
              AuthTextField(
                controller: _nameCtrl,
                label: 'Nama lengkap',
                hint: '',
                enabled: !busy,
                autofillHints: const [AutofillHints.name],
                validator: (v) =>
                    v?.trim().isNotEmpty == true ? null : 'Nama wajib diisi',
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'nama@email.com',
                enabled: !busy,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v?.trim() ?? '')
                    ? null
                    : 'Masukkan email yang valid',
              ),
              const SizedBox(height: 6),
              Text(
                'Perubahan email memerlukan verifikasi ulang.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneCtrl,
                label: 'Nomor telepon (opsional)',
                hint: '',
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
                    : (v) {
                        if (v != null) setState(() => _gender = v);
                      },
              ),
              const SizedBox(height: 16),
              BirthDateField(
                value: _birthDate,
                enabled: !busy,
                onChanged: (date) => setState(() => _birthDate = date),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: 'Simpan perubahan',
                onPressed: _handleUpdate,
                isLoading: busy,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
