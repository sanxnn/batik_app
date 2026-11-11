import 'api_client.dart';

String productImageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  final uri = Uri.tryParse(image);
  if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
    return image;
  }
  final base = Uri.parse(ApiClient.instance.dio.options.baseUrl);
  final path = image.replaceFirst(RegExp(r'^/+'), '');
  return base
      .replace(
        path:
            '${base.path.replaceFirst(RegExp(r'/$'), '')}/storage-image/$path',
      )
      .toString();
}
