import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  ApiClient._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    _setupInterceptors();
  }

  static final ApiClient instance = ApiClient._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _setupInterceptors();

    _isInitialized = true;
  }

  Future<void> _setupInterceptors() async {
    _prefs = await SharedPreferences.getInstance();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs?.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await _prefs?.remove('token');
            debugPrint('⚠️ Sesi berakhir (401), token dihapus.');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
  SharedPreferences? get prefs => _prefs;
}
