import 'package:flutter/material.dart';

class CustomLogoImage extends StatelessWidget {
  final String imgUrl;
  final double? size;
  final Color? color;
  final BoxFit? fit;
  const CustomLogoImage({
    super.key,
    this.size,
    this.color,
    required this.imgUrl,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox();
      },
      image: NetworkImage(imgUrl),
      fit: fit,
      height: size ?? 16,
      width: size ?? 16,
      color: color,
    );
  }
}
