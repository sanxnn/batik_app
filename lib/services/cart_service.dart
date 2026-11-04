import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/utils/api_result.dart';

class CartService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Options> _getAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null &&
          e.response!.data is Map &&
          e.response!.data['message'] != null) {
        return e.response!.data['message'].toString();
      }
    }
    return 'Gagal terhubung ke server. Periksa koneksi Anda.';
  }

  // 1. Ambil isi keranjang belanja user
  Future<ApiResult<dynamic>> getCart() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get('/cart', options: options);
      return ApiResult.success(response.data['data'] ?? response.data);
    } catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  // 2. Tambah produk / varian ke keranjang
  Future<ApiResult<dynamic>> addToCart({
    required int productId,
    required int productVariantId,
    required int quantity,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        '/cart/items',
        data: {
          'product_id': productId,
          'product_variant_id': productVariantId,
          'quantity': quantity,
        },
        options: options,
      );
      return ApiResult.success(response.data);
    } catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  // 3. Update kuantitas
  Future<ApiResult<dynamic>> updateQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '/cart/items/$cartItemId',
        data: {'quantity': quantity},
        options: options,
      );
      return ApiResult.success(response.data);
    } catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  // 4. Hapus item keranjang
  Future<ApiResult<dynamic>> removeCartItem(int cartItemId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.delete('/cart/items/$cartItemId', options: options);
      return ApiResult.success(response.data);
    } catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }
}