import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/custom_order_model.dart';

class CustomOrderPage {
  final List<CustomOrderModel> orders;
  final int currentPage;
  final int lastPage;

  const CustomOrderPage(this.orders, this.currentPage, this.lastPage);
}

class CustomOrderService {
  final Dio _dio;

  CustomOrderService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<CustomOrderPage> getOrders({int page = 1}) async {
    final response = await _dio.get(
      '/custom-orders',
      queryParameters: {'page': page},
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    final meta = body['meta'] is Map
        ? Map<String, dynamic>.from(body['meta'] as Map)
        : const <String, dynamic>{};
    final orders = (body['data'] as List? ?? const [])
        .map(
          (item) =>
              CustomOrderModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    return CustomOrderPage(
      orders,
      (meta['current_page'] as num?)?.toInt() ?? page,
      (meta['last_page'] as num?)?.toInt() ?? page,
    );
  }

  Future<CustomOrderModel> getOrder(int id) async {
    final response = await _dio.get('/custom-orders/$id');
    return CustomOrderModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<CustomOrderModel> create(String description) async {
    final response = await _dio.post(
      '/custom-orders',
      data: {'description': description.trim()},
    );
    return CustomOrderModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<OrderApprovalResult> approve(
    int id, {
    required int addressId,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/custom-orders/$id/approve',
      data: {
        'address_id': addressId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    final data = Map<String, dynamic>.from(response.data['data'] as Map);
    return OrderApprovalResult((data['id'] as num).toInt());
  }

  Future<CustomOrderModel> cancel(int id) async {
    final response = await _dio.post('/custom-orders/$id/cancel');
    return CustomOrderModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}

class OrderApprovalResult {
  final int orderId;

  const OrderApprovalResult(this.orderId);
}
