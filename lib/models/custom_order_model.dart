class CustomOrderModel {
  final int id;
  final String referenceNumber;
  final String description;
  final String status;
  final int? estimatedPrice;
  final String? estimatedTime;
  final String? adminNotes;
  final int? orderId;

  const CustomOrderModel({
    required this.id,
    required this.referenceNumber,
    required this.description,
    required this.status,
    this.estimatedPrice,
    this.estimatedTime,
    this.adminNotes,
    this.orderId,
  });

  factory CustomOrderModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map ? json['order'] as Map : const {};
    return CustomOrderModel(
      id: (json['id'] as num).toInt(),
      referenceNumber: json['reference_number']?.toString() ?? '-',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_review',
      estimatedPrice: (json['estimated_price'] as num?)?.toInt(),
      estimatedTime: json['estimated_time']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      orderId: (order['id'] as num?)?.toInt(),
    );
  }
}
