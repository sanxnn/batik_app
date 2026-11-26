import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';

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
  late DateTime _birthDate;
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
        _gender = user.gender;
        _birthDate = user.birthDate ?? DateTime(2000, 1, 1);
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

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.ink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<AuthController>();
    final success = await controller.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profil berhasil diperbarui'
              : controller.errorMessage ?? 'Gagal memperbarui',
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );

    if (success) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Edit Profil'),
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          if (controller.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informasi dasar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: _nameCtrl,
                              label: 'Nama lengkap',
                              hint: 'Nama lengkap',
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Nama wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _emailCtrl,
                              label: 'Alamat email',
                              hint: 'nama@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Email wajib diisi'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AuthTextField(
                              controller: _phoneCtrl,
                              label: 'Nomor WhatsApp / HP',
                              hint: 'Nomor HP (opsional)',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Informasi pribadi',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jenis kelamin',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _gender,
                              decoration: const InputDecoration(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('Laki-laki'),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('Perempuan'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _gender = v);
                              },
                              validator: (v) =>
                                  v == null ? 'Pilih jenis kelamin' : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Tanggal lahir',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            InkWell(
                              onTap: _pickBirthDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                child: Text(
                                  '${_birthDate.day.toString().padLeft(2, '0')}/'
                                  '${_birthDate.month.toString().padLeft(2, '0')}/'
                                  '${_birthDate.year}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AuthButton(
                        text: 'Simpan Perubahan',
                        isLoading: controller.isLoading,
                        onPressed: controller.isLoading ? null : _handleUpdate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
