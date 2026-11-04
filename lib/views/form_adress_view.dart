
import 'package:batik_app/controllers/adress_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../theme/app_theme.dart';

class AddressFormView extends StatefulWidget {
  final AddressModel? address;

  const AddressFormView({
    super.key,
    this.address,
  });

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _recipientCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _provinceCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _detailCtrl;

  bool _isPrimary = false;

  bool get isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _labelCtrl = TextEditingController(text: address?.label ?? '');
    _recipientCtrl = TextEditingController(
      text: address?.recipientName ?? '',
    );
    _phoneCtrl = TextEditingController(text: address?.phone ?? '');
    _provinceCtrl = TextEditingController(
      text: address?.province ?? '',
    );
    _cityCtrl = TextEditingController(text: address?.city ?? '');
    _districtCtrl = TextEditingController(
      text: address?.district ?? '',
    );
    _postalCtrl = TextEditingController(
      text: address?.postalCode ?? '',
    );
    _detailCtrl = TextEditingController(text: address?.detail ?? '');

    _isPrimary = address?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _recipientCtrl.dispose();
    _phoneCtrl.dispose();
    _provinceCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _postalCtrl.dispose();
    _detailCtrl.dispose();

    super.dispose();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }

    return null;
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'label': _labelCtrl.text.trim(),
      'recipient_name': _recipientCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'province': _provinceCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'district': _districtCtrl.text.trim().isEmpty
          ? null
          : _districtCtrl.text.trim(),
      'postal_code': _postalCtrl.text.trim(),
      'detail': _detailCtrl.text.trim(),
      'is_primary': _isPrimary,
    };

    final controller = context.read<AddressController>();

    final success = isEdit
        ? await controller.updateAddress(widget.address!.id, data)
        : await controller.createAddress(data);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Alamat berhasil diperbarui.'
                : 'Alamat berhasil ditambahkan.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ?? 'Gagal menyimpan alamat.',
          ),
        ),
      );
    }
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            validator: validator ?? _validateRequired,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.surface,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryDark,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Alamat' : 'Tambah Alamat',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Informasi Penerima',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'Label Alamat',
              hint: 'Contoh: Rumah, Kantor',
              controller: _labelCtrl,
              maxLength: 50,
            ),

            _buildField(
              label: 'Nama Penerima',
              hint: 'Masukkan nama penerima',
              controller: _recipientCtrl,
              maxLength: 100,
            ),

            _buildField(
              label: 'Nomor Telepon',
              hint: 'Contoh: 081234567890',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 20,
            ),

            const SizedBox(height: 8),

            const Text(
              'Detail Alamat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildField(
              label: 'Provinsi',
              hint: 'Masukkan provinsi',
              controller: _provinceCtrl,
              maxLength: 100,
            ),

            _buildField(
              label: 'Kota / Kabupaten',
              hint: 'Masukkan kota atau kabupaten',
              controller: _cityCtrl,
              maxLength: 100,
            ),

            _buildField(
              label: 'Kecamatan',
              hint: 'Masukkan kecamatan',
              controller: _districtCtrl,
              maxLength: 100,
            ),

            _buildField(
              label: 'Kode Pos',
              hint: 'Masukkan 5 digit kode pos',
              controller: _postalCtrl,
              keyboardType: TextInputType.number,
              maxLength: 5,
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^\d{5}$').hasMatch(value.trim())) {
                  return 'Kode pos harus terdiri dari 5 angka.';
                }
                return null;
              },
            ),

            _buildField(
              label: 'Alamat Lengkap',
              hint: 'Nama jalan, nomor rumah, RT/RW, patokan, dan lainnya',
              controller: _detailCtrl,
              maxLines: 4,
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: CheckboxListTile(
                value: _isPrimary,
                onChanged: (value) {
                  setState(() {
                    _isPrimary = value ?? false;
                  });
                },
                title: const Text(
                  'Jadikan alamat utama',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  'Gunakan alamat ini sebagai alamat pengiriman utama.',
                  style: TextStyle(fontSize: 12),
                ),
                activeColor: AppTheme.primaryDark,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 24),

            Consumer<AddressController>(
              builder: (context, controller, child) {
                return SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSaving
                        ? null
                        : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Simpan Perubahan' : 'Simpan Alamat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
