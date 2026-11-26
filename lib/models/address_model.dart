class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String province;
  final String city;
  final String? district;
  final String? village;
  final List<String?> regionCodes;
  final String postalCode;
  final String detail;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.province,
    required this.city,
    this.district,
    this.village,
    this.regionCodes = const [null, null, null, null],
    required this.postalCode,
    required this.detail,
    required this.isPrimary,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'] ?? '',
      recipientName: json['recipient_name'] ?? '',
      phone: json['phone'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      district: json['district'],
      village: json['village'],
      regionCodes: [
        'province_code',
        'city_code',
        'district_code',
        'village_code',
      ].map((key) => json[key]?.toString()).toList(growable: false),
      postalCode: json['postal_code'] ?? '',
      detail: json['detail'] ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}
