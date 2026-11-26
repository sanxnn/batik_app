import 'package:batik_app/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';
import '../core/utils/api_error.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/auth_text_field.dart';
import '../widgets/common/app_app_bar.dart';
import '../widgets/common/app_card.dart';

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
  late final TextEditingController _postalCtrl;
  late final TextEditingController _detailCtrl;

  bool _isPrimary = false;
  List<RegionOption> _provinces = [];
  List<RegionOption> _cities = [];
  List<RegionOption> _districts = [];
  List<RegionOption> _villages = [];
  String? _provinceCode, _cityCode, _districtCode, _villageCode;
  bool _regionsLoading = false;
  String? _regionsError;
  int _regionRequest = 0;

  bool get isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();

    final address = widget.address;

    _labelCtrl = TextEditingController(text: address?.label ?? '');
    _recipientCtrl = TextEditingController(text: address?.recipientName ?? '');
    _phoneCtrl = TextEditingController(text: address?.phone ?? '');
    _provinceCode = address?.provinceCode;
    _cityCode = address?.cityCode;
    _districtCode = address?.districtCode;
    _villageCode = address?.villageCode;
    _postalCtrl = TextEditingController(text: address?.postalCode ?? '');
    _detailCtrl = TextEditingController(text: address?.detail ?? '');

    _isPrimary = address?.isPrimary ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialRegions());
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

  Future<void> _loadInitialRegions() async {
    final request = ++_regionRequest;
    setState(() {
      _regionsLoading = true;
      _regionsError = null;
    });
    try {
      final service = context.read<AddressController>();
      final provinces = await service.getProvinces();
      final cities = _provinceCode == null
          ? <RegionOption>[]
          : await service.getRegencies(_provinceCode!);
      final districts = _cityCode == null
          ? <RegionOption>[]
          : await service.getDistricts(_cityCode!);
      final villages = _districtCode == null
          ? <RegionOption>[]
          : await service.getVillages(_districtCode!);
      if (!mounted || request != _regionRequest) return;
      setState(() {
        _provinces = provinces;
        _cities = cities;
        _districts = districts;
        _villages = villages;
        _regionsLoading = false;
      });
    } catch (error) {
      if (!mounted || request != _regionRequest) return;
      setState(() {
        _regionsLoading = false;
        _regionsError = apiErrorMessage(error);
      });
    }
  }

  Future<void> _selectRegion(int level, String? code) async {
    final request = ++_regionRequest;
    setState(() {
      _regionsError = null;
      if (level == 0) {
        _provinceCode = code;
        _cityCode = null;
        _districtCode = null;
        _villageCode = null;
        _cities = [];
        _districts = [];
        _villages = [];
      }
      if (level == 1) {
        _cityCode = code;
        _districtCode = null;
        _villageCode = null;
        _districts = [];
        _villages = [];
      }
      if (level == 2) {
        _districtCode = code;
        _villageCode = null;
        _villages = [];
      }
      if (level == 3) _villageCode = code;
      _regionsLoading = level < 3 && code != null;
    });
    if (level == 3 || code == null) return;
    try {
      final service = context.read<AddressController>();
      final options = level == 0
          ? await service.getRegencies(code)
          : level == 1
          ? await service.getDistricts(code)
          : await service.getVillages(code);
      if (!mounted || request != _regionRequest) return;
      setState(() {
        if (level == 0) _cities = options;
        if (level == 1) _districts = options;
        if (level == 2) _villages = options;
        _regionsLoading = false;
      });
    } catch (error) {
      if (!mounted || request != _regionRequest) return;
      setState(() {
        _regionsLoading = false;
        _regionsError = apiErrorMessage(error);
      });
    }
  }

  Widget _regionField(
    String label,
    List<RegionOption> options,
    String? code,
    int level,
    bool enabled,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label-$code'),
      initialValue: options.any((item) => item.code == code) ? code : null,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (item) => DropdownMenuItem(
              value: item.code,
              child: Text(item.name, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled && !_regionsLoading
          ? (value) => _selectRegion(level, value)
          : null,
      validator: (value) {
        if (level == 0 &&
            isEdit &&
            widget.address!.provinceCode == null &&
            _provinceCode == null) {
          return null;
        }
        return value == null ? 'Pilih $label.' : null;
      },
    ),
  );

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final legacy =
        isEdit && widget.address!.provinceCode == null && _provinceCode == null;
    if (!legacy &&
        (_provinceCode == null ||
            _cityCode == null ||
            _districtCode == null ||
            _villageCode == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih wilayah hingga desa atau kelurahan.'),
        ),
      );
      return;
    }
    final data = <String, dynamic>{
      'label': _labelCtrl.text.trim(),
      'recipient_name': _recipientCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      if (legacy) ...{
        'province': widget.address!.province,
        'city': widget.address!.city,
        'district': widget.address!.district,
      } else ...{
        'province_code': _provinceCode,
        'city_code': _cityCode,
        'district_code': _districtCode,
        'village_code': _villageCode,
      },
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AuthTextField(
        controller: controller,
        label: label,
        hint: hint,
        keyboardType: keyboardType,
        validator: validator ?? _validateRequired,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: isEdit ? 'Edit Alamat' : 'Tambah Alamat'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(
              'Informasi Penerima',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),

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

            const SizedBox(height: AppSpacing.xs),

            Text(
              'Detail Alamat',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: AppSpacing.md),

            if (isEdit && widget.address!.provinceCode == null)
              Text(
                'Wilayah tersimpan: ${widget.address!.district ?? ''}, '
                '${widget.address!.city}, ${widget.address!.province}. '
                'Pilih provinsi untuk memperbarui wilayah.',
              ),
            if (_regionsLoading) const LinearProgressIndicator(),
            if (_regionsError != null) ...[
              Text(
                _regionsError!,
                style: const TextStyle(color: AppColors.danger),
              ),
              TextButton(
                onPressed: _loadInitialRegions,
                child: const Text('Coba lagi'),
              ),
            ],
            if (!(isEdit &&
                widget.address!.provinceCode == null &&
                _provinceCode == null)) ...[
              _regionField('Provinsi', _provinces, _provinceCode, 0, true),
              _regionField(
                'Kota / Kabupaten',
                _cities,
                _cityCode,
                1,
                _provinceCode != null,
              ),
              _regionField(
                'Kecamatan',
                _districts,
                _districtCode,
                2,
                _cityCode != null,
              ),
              _regionField(
                'Desa / Kelurahan',
                _villages,
                _villageCode,
                3,
                _districtCode != null,
              ),
            ] else
              _regionField(
                'Pilih provinsi baru (opsional)',
                _provinces,
                _provinceCode,
                0,
                true,
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

            const SizedBox(height: AppSpacing.xs),

            AppCard(
              child: CheckboxListTile(
                value: _isPrimary,
                onChanged: (value) =>
                    setState(() => _isPrimary = value ?? false),
                title: const Text('Jadikan alamat utama'),
                subtitle: const Text(
                  'Gunakan alamat ini sebagai alamat pengiriman utama.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Consumer<AddressController>(
              builder: (context, controller, _) => AuthButton(
                text: isEdit ? 'Simpan Perubahan' : 'Simpan Alamat',
                isLoading: controller.isSaving,
                onPressed: controller.isSaving ? null : _saveAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
