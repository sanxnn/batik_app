import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? _placeholder()
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _placeholder(loading: true);
            },
            errorBuilder: (_, _, _) => _placeholder(),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.imagePlaceholder,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.warningText,
            ),
    );
  }
}
