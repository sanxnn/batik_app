import 'package:file_selector/file_selector.dart';

const commerceImages = XTypeGroup(
  label: 'Gambar JPEG, PNG, atau WebP',
  extensions: ['jpg', 'jpeg', 'png', 'webp'],
  mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
  uniformTypeIdentifiers: ['public.jpeg', 'public.png', 'org.webmproject.webp'],
);

Future<bool> isSupportedImage(XFile file, int maxBytes) async {
  final extension = file.name.split('.').last.toLowerCase();
  return const ['jpg', 'jpeg', 'png', 'webp'].contains(extension) &&
      await file.length() <= maxBytes;
}
