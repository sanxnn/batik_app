import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/utils/api_result.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;
  final _prefs = ApiClient.instance.prefs;

  String _extractErrorMessage(DioException e) {
    if (e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    if (e.response?.data['errors'] != null) {
      final errors = e.response!.data['errors'] as Map<String, dynamic>;
      return errors.values.first.first;
    }
    return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
  }

  Future<ApiResult<UserModel>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      if (data['token'] != null) {
        await _prefs?.setString('token', data['token']);
      }

      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(
        _extractErrorMessage(e),
        errors: e.response?.data['errors'],
      );
    }
  }

  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String gender,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'birth_date': birthDate.toIso8601String().split('T').first,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data['data'];
      // if (data['token'] != null) {
      //   await _prefs?.setString('token', data['token']);
      // }

      final user = UserModel.fromJson(data['user']);
      return ApiResult.success(user, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(
        _extractErrorMessage(e),
        errors: e.response?.data['errors'],
      );
    }
  }

  Future<ApiResult<UserModel>> verifyEmail(String email, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/email/verify',
        data: {'email': email, 'otp': otp},
      );

      final data = response.data['data'];
      UserModel? user;
      if (data['user'] != null) {
        user = UserModel.fromJson(data['user']);
      }
      return ApiResult.success(user, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<void>> resendVerificationOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/email/resend',
        data: {'email': email},
      );
      return ApiResult.success(null, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<void>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/password/forgot',
        data: {'email': email},
      );
      return ApiResult.success(null, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> verifyPasswordResetOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/password/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      
      return ApiResult.success(
        data,
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return ApiResult.error(
        _extractErrorMessage(e),
        errors: e.response?.data['errors'],
      );
    }
  }

  Future<ApiResult<void>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'reset_token': resetToken,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return ApiResult.success(null, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(
        _extractErrorMessage(e),
        errors: e.response?.data['errors'],
      );
    }
  }

  Future<ApiResult<UserModel>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      final user = UserModel.fromJson(response.data['data']);
      return ApiResult.success(user, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(_extractErrorMessage(e));
    }
  }

  Future<ApiResult<UserModel>> updateProfile({
    required String name,
    required String email,
    required String gender,
    required DateTime birthDate,
    String? phone,
  }) async {
    try {
      final response = await _dio.put(
        '/auth/profile',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'gender': gender,
          'birth_date': birthDate.toIso8601String().split('T').first,
        },
      );

      final user = UserModel.fromJson(response.data['data']['user']);
      return ApiResult.success(user, message: response.data['message']);
    } on DioException catch (e) {
      return ApiResult.error(
        _extractErrorMessage(e),
        errors: e.response?.data['errors'],
      );
    }
  }

  Future<ApiResult<void>> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      await _prefs?.remove('token');
    }
    return ApiResult.success(null, message: 'Logout berhasil');
  }
}
