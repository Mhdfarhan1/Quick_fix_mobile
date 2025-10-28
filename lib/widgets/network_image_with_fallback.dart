import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const NetworkImageWithFallback({
    super.key,
    this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(
        'assets/default.jpg',
        height: height,
        width: width,
        fit: fit,
      );
    }

    return Image.network(
      imageUrl!,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $imageUrl');
        return Image.asset(
          'assets/default.jpg',
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
}
