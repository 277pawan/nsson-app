import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BrandLogoImage extends StatelessWidget {
  final String logo;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const BrandLogoImage({
    super.key,
    required this.logo,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (logo.startsWith('assets/')) {
      return Image.asset(
        logo,
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (logo.isEmpty) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: logo,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _placeholder(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.borderLight,
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_outlined,
        color: AppColors.textTertiary,
        size: width * 0.45,
      ),
    );
  }
}
