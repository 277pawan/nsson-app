import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorChild;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorChild,
  });

  @override
  Widget build(BuildContext context) {
    final child = imageUrl.trim().isEmpty
        ? _FallbackImage(
            height: height,
            width: width,
            child: errorChild,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            height: height,
            width: width,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 220),
            fadeOutDuration: const Duration(milliseconds: 120),
            placeholder: (_, __) => _ImageSkeleton(
              height: height,
              width: width,
            ),
            errorWidget: (_, __, ___) => _FallbackImage(
              height: height,
              width: width,
              child: errorChild,
            ),
          );

    if (borderRadius == null) return child;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  final double? height;
  final double? width;

  const _ImageSkeleton({
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: height,
      width: width,
      color: const Color(0xFFE9EEF6),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;

  const _FallbackImage({
    this.height,
    this.width,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE9EEF6),
      alignment: Alignment.center,
      child: child ??
          const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF94A3B8),
          ),
    );
  }
}
