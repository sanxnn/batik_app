class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String gender;
  final DateTime? birthDate;
  final String role;
  final DateTime? emailVerifiedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.gender,
    this.birthDate,
    required this.role,
    this.emailVerifiedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'] ?? 'male',
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      role: json['role'] ?? 'customer',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'role': role,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }

  bool get isEmailVerified => emailVerifiedAt != null;

  String get genderLabel => gender == 'male' ? 'Laki-laki' : 'Perempuan';

  String get formattedBirthDate {
    if (birthDate == null) return '-';
    return '${birthDate!.day.toString().padLeft(2, '0')}/'
        '${birthDate!.month.toString().padLeft(2, '0')}/'
        '${birthDate!.year}';
  }
}
