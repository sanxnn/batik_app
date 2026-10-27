import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/utils/api_result.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final Dio _dio = ApiClient.instance.dio;

  String _extractErrorMessage(DioException e) {
    if (e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    return 'Gagal memuat data. Periksa koneksi Anda.';
  }

  Future<ApiResult<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data['data'];
      final categories = data.map((json) => CategoryModel.fromJson(json)).toList();
      return ApiResult.success(categories);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<List<ProductModel>>> getProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (categoryId != null) 'category_id': categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final Map<String, dynamic> paginationData = response.data['data'];
      final List<dynamic> productsJson = paginationData['data'];

      final products = productsJson.map((json) => ProductModel.fromJson(json)).toList();
      return ApiResult.success(products);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }
}