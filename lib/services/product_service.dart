import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/utils/api_result.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final Dio _dio;
  ProductService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

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
      final categories = data
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      return ApiResult.success(categories);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<ProductModel>> getProduct(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ApiResult.success(ProductModel.fromJson(response.data['data']));
    } on DioException catch (error) {
      return ApiResult.error(_extractErrorMessage(error));
    } catch (_) {
      return ApiResult.error('Detail produk tidak dapat diproses.');
    }
  }

  Future<ApiResult<ProductPage>> getProducts({
    int? categoryId,
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/products',
        queryParameters: {
          'category_id': ?categoryId,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
        },
      );

      final Map<String, dynamic> paginationData = response.data['data'];
      final List<dynamic> productsJson = paginationData['data'];

      final products = productsJson
          .map((json) => ProductModel.fromJson(json))
          .toList();
      return ApiResult.success(
        ProductPage(
          products,
          (paginationData['current_page'] as num).toInt(),
          (paginationData['last_page'] as num).toInt(),
        ),
      );
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }
}

class ProductPage {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  const ProductPage(this.products, this.currentPage, this.lastPage);
}
