class RefundModel {
  final int id;
  final String status;
  final int amount;
  final String? orderNumber;
  final String? reason;
  final String? adminNotes;
  final String? method;
  final String? manualReference;
  final String? completedAt;

  const RefundModel({
    required this.id,
    required this.status,
    required this.amount,
    this.orderNumber,
    this.reason,
    this.adminNotes,
    this.method,
    this.manualReference,
    this.completedAt,
  });

  factory RefundModel.fromJson(Map json) => RefundModel(
    id: (json['id'] as num).toInt(),
    status: json['status'] as String,
    amount: num.tryParse(json['amount'].toString())?.toInt() ?? 0,
    orderNumber: json['order_number'] as String?,
    reason: json['reason'] as String?,
    adminNotes: json['admin_notes'] as String?,
    method: json['refund_method'] as String?,
    manualReference: json['manual_reference'] as String?,
    completedAt: json['completed_at'] as String?,
  );

  bool get allowsNewRequest => status == 'rejected' || status == 'cancelled';

  String get statusLabel => switch (status) {
    'pending' => 'Menunggu peninjauan',
    'approved' => 'Disetujui',
    'processing' => 'Diproses',
    'completed' => 'Dana dikembalikan',
    'rejected' => 'Ditolak',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };
}
