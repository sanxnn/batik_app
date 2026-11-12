import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/bundle_model.dart';

class BundlePage {
  final List<BundleModel> bundles;
  final int currentPage;
  final int lastPage;

  const BundlePage(this.bundles, this.currentPage, this.lastPage);
}

class BundleService {
  final Dio _dio;

  BundleService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<BundlePage> getBundles({String? search, int page = 1}) async {
    final response = await _dio.get(
      '/bundles',
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
      },
    );
    final body = Map<String, dynamic>.from(response.data as Map);
    final items = (body['data'] as List? ?? const [])
        .map(
          (item) =>
              BundleModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final meta = body['meta'] is Map
        ? Map<String, dynamic>.from(body['meta'] as Map)
        : const <String, dynamic>{};
    return BundlePage(
      items,
      (meta['current_page'] as num?)?.toInt() ?? page,
      (meta['last_page'] as num?)?.toInt() ?? page,
    );
  }

  Future<BundleModel> getBundle(int id) async {
    final response = await _dio.get('/bundles/$id');
    return BundleModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}
