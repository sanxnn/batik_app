import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/utils/api_result.dart';
import '../models/address_model.dart';

class AddressService {
  final Dio _dio = ApiClient.instance.dio;

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }

    return 'Terjadi kesalahan. Periksa koneksi Anda.';
  }

  // GET: Semua alamat
  Future<ApiResult<List<AddressModel>>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');

      final List<dynamic> data = response.data['data'];

      final addresses = data
          .map((json) => AddressModel.fromJson(json))
          .toList();

      return ApiResult.success(addresses);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal memproses data alamat.');
    }
  }

  // GET: Detail alamat
  Future<ApiResult<AddressModel>> getAddress(int id) async {
    try {
      final response = await _dio.get('/addresses/$id');

      final address = AddressModel.fromJson(response.data['data']);

      return ApiResult.success(address);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal mengambil detail alamat.');
    }
  }

  // POST: Tambah alamat
  Future<ApiResult<AddressModel>> createAddress(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/addresses', data: data);

      final address = AddressModel.fromJson(response.data['data']);

      return ApiResult.success(address);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal menambahkan alamat.');
    }
  }

  // PUT: Update alamat
  Future<ApiResult<AddressModel>> updateAddress(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/addresses/$id', data: data);

      final address = AddressModel.fromJson(response.data['data']);

      return ApiResult.success(address);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal memperbarui alamat.');
    }
  }

  // DELETE: Hapus alamat
  Future<ApiResult<bool>> deleteAddress(int id) async {
    try {
      await _dio.delete('/addresses/$id');

      return ApiResult.success(true);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal menghapus alamat.');
    }
  }

  // PATCH: Jadikan alamat utama
  Future<ApiResult<AddressModel>> setPrimary(int id) async {
    try {
      final response = await _dio.patch('/addresses/$id/primary');

      final address = AddressModel.fromJson(response.data['data']);

      return ApiResult.success(address);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    } catch (e) {
      return ApiResult.error('Gagal mengubah alamat utama.');
    }
  }
}
