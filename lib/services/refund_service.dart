import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';

class RefundRequestModel {
  final int id;
  final int orderId;
  final String? orderNumber;
  final String reason;
  final String status;
  final String? adminNotes;
  final String? method;
  final String? manualReference;
  final int amount;
  final DateTime? createdAt;

  const RefundRequestModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.reason,
    required this.status,
    required this.adminNotes,
    required this.method,
    required this.manualReference,
    required this.amount,
    required this.createdAt,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) =>
      RefundRequestModel(
        id: (json['id'] as num).toInt(),
        orderId: (json['order_id'] as num).toInt(),
        orderNumber: json['order_number']?.toString(),
        reason: json['reason']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        adminNotes: json['admin_notes']?.toString(),
        method: json['refund_method']?.toString(),
        manualReference: json['manual_reference']?.toString(),
        amount: (json['amount'] as num).toInt(),
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      );
}

class RefundService {
  final Dio _dio;

  RefundService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<RefundRequestModel> get(int id) async {
    final response = await _dio.get('/refunds/$id');
    return RefundRequestModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<RefundRequestModel> submit({
    required int orderId,
    required String reason,
    required XFile evidence,
  }) async {
    final form = FormData.fromMap({
      'reason': reason.trim(),
      'evidence': MultipartFile.fromBytes(
        await evidence.readAsBytes(),
        filename: evidence.name,
      ),
    });
    final response = await _dio.post(
      '/orders/$orderId/refund',
      data: form,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    return RefundRequestModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}
