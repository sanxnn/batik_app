class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String province;
  final String? provinceCode;
  final String city;
  final String? cityCode;
  final String? district;
  final String? districtCode;
  final String? village;
  final String? villageCode;
  final String postalCode;
  final String detail;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.province,
    this.provinceCode,
    required this.city,
    this.cityCode,
    this.district,
    this.districtCode,
    this.village,
    this.villageCode,
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
      provinceCode: json['province_code']?.toString(),
      city: json['city'] ?? '',
      cityCode: json['city_code']?.toString(),
      district: json['district'],
      districtCode: json['district_code']?.toString(),
      village: json['village']?.toString(),
      villageCode: json['village_code']?.toString(),
      postalCode: json['postal_code'] ?? '',
      detail: json['detail'] ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}
