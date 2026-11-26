class CustomOrderModel {
  final int id;
  final String referenceNumber;
  final String description;
  final String status;
  final int? estimatedPrice;
  final String? estimatedTime;
  final String? adminNotes;
  final int? orderId;
  final List<String> attachmentPaths;

  String get statusLabel => switch (status) {
    'pending_review' => 'Menunggu peninjauan',
    'quoted' => 'Penawaran tersedia',
    'approved' => 'Penawaran disetujui',
    'rejected' => 'Ditolak',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };

  const CustomOrderModel({
    required this.id,
    required this.referenceNumber,
    required this.description,
    required this.status,
    this.estimatedPrice,
    this.estimatedTime,
    this.adminNotes,
    this.orderId,
    this.attachmentPaths = const [],
  });

  factory CustomOrderModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map ? json['order'] as Map : const {};
    return CustomOrderModel(
      id: (json['id'] as num).toInt(),
      referenceNumber: json['reference_number']?.toString() ?? '-',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_review',
      estimatedPrice: num.tryParse(json['estimated_price'].toString())?.toInt(),
      estimatedTime: json['estimated_time']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      attachmentPaths: (json['attachments'] as List? ?? const [])
          .map((item) => (item as Map)['file_path'])
          .whereType<String>()
          .toList(),
      orderId: (order['id'] as num?)?.toInt(),
    );
  }
}
