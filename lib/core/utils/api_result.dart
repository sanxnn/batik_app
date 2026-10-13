class ApiResult<T> {
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final bool isSuccess;

  ApiResult.success(this.data, {this.message = 'Berhasil'})
      : isSuccess = true,
        errors = null;

  ApiResult.error(this.message, {this.data, this.errors}) : isSuccess = false;
}