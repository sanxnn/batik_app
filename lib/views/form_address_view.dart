import 'package:batik_app/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../core/utils/api_error.dart';
import '../services/address_service.dart';
import '../theme/app_theme.dart';

class AddressFormView extends StatefulWidget {
  final AddressModel? address;

  const AddressFormView({super.key, this.address});

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _recipientCtrl;
  late final TextEditingController _phoneCtrl;
  final _addressService = AddressService();
  static const _regionLabels = [
    'Provinsi',
    'Kabupaten / Kota',
    'Kecamatan',
    'Desa / Kelurahan',
  ];
  static const _regionPaths = [
    'provinces',
    'regencies',
    'districts',
    'villages',
  ];
  static const _regionKeys = [
    'province_code',
    'city_code',
    'district_code',
    'village_code',
  ];
  late final List<String?> _codes;
  final _options = List.generate(4, (_) => <({String code, String name})>[]);
  int? _loadingRegion;
  int? _failedRegion;
  String? _regionError;

  late final TextEditingController _postalCtrl;
  late final TextEditingController _detailCtrl;

  bool _isPrimary = false;

  bool get isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _labelCtrl = TextEditingController(text: address?.label ?? '');
    _recipientCtrl = TextEditingController(text: address?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: address?.phone ?? '');
    _codes = List.of(address?.regionCodes ?? const [null, null, null, null]);
    _loadRegion(0, restore: true);
    _postalCtrl = TextEditingController(text: address?.postalCode ?? '');
    _detailCtrl = TextEditingController(text: address?.detail ?? '');

    _isPrimary = address?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _recipientCtrl.dispose();
    _phoneCtrl.dispose();
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

  Future<void> _loadRegion(int level, {bool restore = false}) async {
    final parent = level == 0 ? null : _codes[level - 1];
    setState(() {
      _loadingRegion = level;
      _failedRegion = null;
      _regionError = null;
    });
    try {
      final path = parent == null
          ? _regionPaths[level]
          : '${_regionPaths[level]}/$parent';
      final options = await _addressService.getRegions(path);
      if (!mounted) return;
      final valid = options.any((option) => option.code == _codes[level]);
      setState(() {
        _options[level] = options;
        _loadingRegion = null;
        if (!valid) _codes.fillRange(level, _codes.length, null);
      });
      if (restore && valid && level < _codes.length - 1) {
        await _loadRegion(level + 1, restore: true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingRegion = null;
        _failedRegion = level;
        _regionError = apiErrorMessage(error);
      });
    }
  }

  Widget _regionDropdown(int level) => InputDecorator(
    decoration: InputDecoration(labelText: _regionLabels[level]),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: _options[level].any((option) => option.code == _codes[level])
            ? _codes[level]
            : null,
        hint: Text('Pilih ${_regionLabels[level]}'),
        items: _options[level]
            .map(
              (option) => DropdownMenuItem(
                value: option.code,
                child: Text(option.name, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: _loadingRegion != null || _options[level].isEmpty
            ? null
            : (value) {
                setState(() {
                  _codes[level] = value;
                  for (var next = level + 1; next < _codes.length; next++) {
                    _codes[next] = null;
                    _options[next] = [];
                  }
                  _regionError = null;
                  _failedRegion = null;
                });
                if (value != null && level < _codes.length - 1) {
                  _loadRegion(level + 1);
                }
              },
      ),
    ),
  );

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    if (_loadingRegion != null) return;
    if (_codes.any((code) => code == null) || _failedRegion != null) {
      setState(
        () => _regionError = 'Pilih wilayah hingga desa atau kelurahan.',
      );
      return;
    }
    final data = <String, dynamic>{
      'label': _labelCtrl.text.trim(),
      'recipient_name': _recipientCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      for (var i = 0; i < _regionKeys.length; i++) _regionKeys[i]: _codes[i],
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
          content: Text(controller.errorMessage ?? 'Gagal menyimpan alamat.'),
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
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (widget.address case final address?)
              if (address.regionCodes.every((code) => code == null))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Wilayah tersimpan: ${[address.district, address.city, address.province].whereType<String>().join(', ')}. Pilih kode wilayah sebelum menyimpan.',
                  ),
                ),
            for (var level = 0; level < _regionLabels.length; level++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _regionDropdown(level),
              ),
            if (_loadingRegion != null) const LinearProgressIndicator(),
            if (_regionError != null)
              Text(
                _regionError!,
                style: const TextStyle(color: AppTheme.error),
              ),
            if (_failedRegion case final level?)
              TextButton(
                onPressed: () => _loadRegion(level, restore: true),
                child: const Text('Coba lagi'),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                    onPressed: controller.isSaving ? null : _saveAddress,
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
