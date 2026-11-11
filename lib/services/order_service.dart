import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderPage {
  final List<OrderModel> orders;
  final int currentPage;
  final int lastPage;
  const OrderPage(this.orders, this.currentPage, this.lastPage);
}

class CheckoutResult {
  final OrderModel order;
  final String? snapToken;
  const CheckoutResult(this.order, this.snapToken);
}

class OrderService {
  final Dio _dio;
  OrderService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<OrderPage> getOrders({int page = 1}) async {
    final response = await _dio.get('/orders', queryParameters: {'page': page});
    final body = response.data as Map;
    final meta = body['meta'] is Map ? body['meta'] as Map : const {};
    final orders = (body['data'] as List)
        .map(
          (item) => OrderModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    return OrderPage(
      orders,
      (meta['current_page'] as num?)?.toInt() ?? page,
      (meta['last_page'] as num?)?.toInt() ?? page,
    );
  }

  Future<OrderModel> getOrder(int id) async {
    final response = await _dio.get('/orders/$id');
    return OrderModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<CheckoutResult> checkout({
    required int addressId,
    String? voucherCode,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'address_id': addressId,
        if (voucherCode != null && voucherCode.isNotEmpty)
          'voucher_code': voucherCode,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    final data = response.data['data'] as Map;
    final payment = data['payment'] is Map ? data['payment'] as Map : const {};
    return CheckoutResult(
      OrderModel.fromJson(Map<String, dynamic>.from(data['order'] as Map)),
      payment['snap_token']?.toString(),
    );
  }

  Future<String?> getSnapToken(int id) async {
    final response = await _dio.post('/payments/$id/snap-token');
    return response.data['data']['snap_token']?.toString();
  }

  Future<OrderModel> cancelOrder(int id) async {
    final response = await _dio.post('/orders/$id/cancel');
    return OrderModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}
