import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';

import '../core/network/api_client.dart';
import '../models/refund_model.dart';

class RefundService {
  final Dio _dio;

  RefundService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<RefundModel> submit(int orderId, String reason, XFile evidence) async {
    final response = await _dio.post(
      '/orders/$orderId/refund',
      data: FormData.fromMap({
        'reason': reason,
        'evidence': MultipartFile.fromBytes(
          await evidence.readAsBytes(),
          filename: evidence.name,
        ),
      }),
    );
    return RefundModel.fromJson(response.data['data'] as Map);
  }

  Future<RefundModel> detail(int id) async {
    final response = await _dio.get('/refunds/$id');
    return RefundModel.fromJson(response.data['data'] as Map);
  }

  Future<RefundModel> cancel(int id) async {
    final response = await _dio.post('/refunds/$id/cancel');
    return RefundModel.fromJson(response.data['data'] as Map);
  }

  Future<Uint8List> evidence(int id) async {
    final response = await _dio.get<Uint8List>(
      '/refunds/$id/evidence',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data!;
  }

  Future<({List<RefundModel> items, bool hasMore})> list(int page) async {
    final response = await _dio.get(
      '/refunds',
      queryParameters: {'page': page},
    );
    final body = response.data as Map;
    return (
      items: (body['data'] as List)
          .map((item) => RefundModel.fromJson(item as Map))
          .toList(),
      hasMore: body['links']?['next'] != null,
    );
  }
}
