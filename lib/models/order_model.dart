import 'refund_model.dart';

class OrderModel {
  final int id;
  final String number;
  final String status;
  final DateTime? createdAt;
  final int total;
  final int subtotal;
  final int discount;
  final int shippingCost;
  final String? snapToken;
  final String? paymentStatus;
  final String? recipient;
  final String? shippingAddress;
  final List<OrderItemModel> items;
  final String? courier;
  final String? trackingNumber;
  final RefundModel? refund;
  final bool isCustomOrder;

  bool get canComplete => status == 'shipped' && paymentStatus == 'success';

  bool get canRequestRefund =>
      paymentStatus == 'success' &&
      const [
        'paid',
        'processing',
        'packing',
        'shipped',
        'completed',
        'cancelled',
      ].contains(status) &&
      (refund?.allowsNewRequest ?? true);

  const OrderModel({
    required this.id,
    required this.number,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.discount,
    required this.shippingCost,
    required this.items,
    this.createdAt,
    this.snapToken,
    this.paymentStatus,
    this.recipient,
    this.shippingAddress,
    this.courier,
    this.trackingNumber,
    this.refund,
    this.isCustomOrder = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] is Map ? json['pricing'] as Map : const {};
    final payment = json['payment'] is Map ? json['payment'] as Map : const {};
    final address = json['address'] is Map ? json['address'] as Map : const {};
    final shipping = json['shipping'] is Map
        ? json['shipping'] as Map
        : const {};
    final refund = json['refund'];
    final addressParts = [
      address['detail'],
      address['village'],
      address['district'],
      address['city'],
      address['province'],
      address['postal_code'],
    ].where((value) => value != null && value.toString().isNotEmpty).join(', ');
    return OrderModel(
      id: (json['id'] as num).toInt(),
      number: json['order_number']?.toString() ?? '-',
      status: json['status']?.toString() ?? '-',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      total: _rupiah(pricing['final_amount']),
      subtotal: _rupiah(pricing['subtotal']),
      discount: _rupiah(pricing['total_discount']),
      shippingCost: _rupiah(pricing['shipping_cost']),
      snapToken: payment['snap_token']?.toString(),
      paymentStatus: payment['payment_status']?.toString(),
      recipient: address['recipient_name']?.toString(),
      shippingAddress: addressParts.isEmpty ? null : addressParts,
      courier: shipping['courier']?.toString(),
      trackingNumber: shipping['resi_number']?.toString(),
      refund: refund is Map ? RefundModel.fromJson(refund) : null,
      isCustomOrder: json['is_custom_order'] == true,
      items: (json['items'] as List? ?? const [])
          .map(
            (item) =>
                OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}

class OrderItemModel {
  final String name;
  final String variant;
  final int quantity;
  final int subtotal;

  const OrderItemModel({
    required this.name,
    required this.variant,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    name: json['product_name']?.toString() ?? 'Produk',
    variant: json['variant_name']?.toString() ?? '',
    quantity: _rupiah(json['quantity']),
    subtotal: _rupiah(json['subtotal']),
  );
}

int _rupiah(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

String formatRupiah(num value) {
  final digits = value.toInt().toString();
  return 'Rp ${digits.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
}
