import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/auth/auth_layout.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/auth/auth_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _gender = 'male';
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

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 17, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      helpText: 'Pilih tanggal lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: AppTheme.textPrimary,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi')),
      );
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    final controller = context.read<AuthController>();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return AuthLayout(
          title: 'Buat akun baru ✨',
          subtitle:
              'Bergabunglah dengan Batik Rubung Kuning '
              'dan temukan cerita di setiap karya.',
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama lengkap
                AuthTextField(
                  controller: _nameCtrl,
                  label: 'Nama lengkap',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email
                AuthTextField(
                  controller: _emailCtrl,
                  label: 'Alamat email',
                  hint: 'nama@email.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
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

                const SizedBox(height: 20),

                // Nomor telepon opsional
                AuthTextField(
                  controller: _phoneCtrl,
                  label: 'Nomor HP',
                  hint: '08xxxxxxxxxx (opsional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                // Jenis kelamin
                const Text(
                  'Jenis kelamin',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _gender,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSecondary,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'male',
                          child: Row(
                            children: [
                              Icon(
                                Icons.male_rounded,
                                color: AppTheme.textSecondary,
                                size: 21,
                              ),
                              SizedBox(width: 12),
                              Text('Laki-laki'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Row(
                            children: [
                              Icon(
                                Icons.female_rounded,
                                color: AppTheme.textSecondary,
                                size: 21,
                              ),
                              SizedBox(width: 12),
                              Text('Perempuan'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _gender = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tanggal lahir
                const Text(
                  'Tanggal lahir',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 9),

                Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: InkWell(
                    onTap: _pickBirthDate,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: AppTheme.textSecondary,
                            size: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _birthDate == null
                                  ? 'Pilih tanggal lahir'
                                  : _formatDate(_birthDate!),
                              style: TextStyle(
                                color: _birthDate == null
                                    ? AppTheme.textHint
                                    : AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password
                AuthTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  hint: 'Minimal 8 karakter',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 21,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Konfirmasi password
                AuthTextField(
                  controller: _confirmPasswordCtrl,
                  label: 'Konfirmasi password',
                  hint: 'Masukkan ulang password',
                  icon: Icons.lock_reset_rounded,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    tooltip: _obscureConfirmPassword
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textSecondary,
                      size: 21,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }

                    if (value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }

                    if (value != _passwordCtrl.text) {
                      return 'Password tidak cocok';
                    }

                    return null;
                  },
                  onSubmitted: (_) {
                    if (!controller.isLoading) {
                      _handleRegister();
                    }
                  },
                ),

                const SizedBox(height: 28),

                // Tombol daftar global
                AuthButton(
                  text: 'Buat Akun',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: controller.isLoading,
                  onPressed: _handleRegister,
                ),

                const SizedBox(height: 24),

                // Navigasi login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text(
                        'Sudah punya akun?',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Masuk'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppTheme.textSecondary,
                        size: 15,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Data kamu diproses dengan aman',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
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
