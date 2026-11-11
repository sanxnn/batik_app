import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final body = error.response?.data;
    if (body is Map) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) return message;
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    if (error.response?.statusCode == 401) {
      return 'Sesi berakhir. Silakan masuk kembali.';
    }
    return 'Koneksi gagal. Silakan coba lagi.';
  }
  return 'Data dari server tidak dapat diproses.';
}
