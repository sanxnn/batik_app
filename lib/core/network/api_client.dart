import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'token_store.dart';

class ApiClient {
  late final Dio _dio;
  bool _isInitialized = false;

  ApiClient._internal() {
    final baseUrl =
        dotenv.env['API_BASE_URL'] ??
        'https://batikrubungkuning.sanxnn.my.id/api';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    await TokenStore.instance.init();
    _setupInterceptors();

    _isInitialized = true;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenStore.instance.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await TokenStore.instance.clear();
            debugPrint('⚠️ Sesi berakhir (401), token dihapus.');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
