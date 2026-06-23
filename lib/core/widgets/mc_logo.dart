import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Moto Crafter logo widget - uses assets/logo.png.
class McLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool withShadow;
  final double paddingFactor;

  const McLogo({
    super.key,
    this.size = 40,
    this.borderRadius = 11,
    this.withShadow = false,
    this.paddingFactor = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.26),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.primaryLight.withOpacity(0.24),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(size * paddingFactor),
            child: Image.asset(
              'assets/logo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class GlitchLogoReveal extends StatefulWidget {
  final double size;
  final double borderRadius;
  final bool withShadow;

  const GlitchLogoReveal({
    super.key,
    required this.size,
    required this.borderRadius,
    this.withShadow = true,
  });

  @override
  State<GlitchLogoReveal> createState() => _GlitchLogoRevealState();
}

class _GlitchLogoRevealState extends State<GlitchLogoReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1450),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = McLogo(
      size: widget.size,
      borderRadius: widget.borderRadius,
      withShadow: widget.withShadow,
      paddingFactor: 0.1,
    );

    return AnimatedBuilder(
      animation: _controller,
      child: logo,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final glitchStrength = (1 - Curves.easeOut.transform(progress)).clamp(
          0.0,
          1.0,
        );

        return Transform.scale(
          scale: 0.92 + (progress * 0.08),
          child: Opacity(
            opacity: (progress * 1.15).clamp(0.0, 1.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                child!,
                _GlitchSliceOverlay(
                  size: widget.size,
                  borderRadius: widget.borderRadius,
                  progress: glitchStrength,
                  tint: const Color(0x332563EB),
                  direction: -1,
                ),
                _GlitchSliceOverlay(
                  size: widget.size,
                  borderRadius: widget.borderRadius,
                  progress: glitchStrength * 0.85,
                  tint: const Color(0x22EF4444),
                  direction: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlitchSliceOverlay extends StatelessWidget {
  final double size;
  final double borderRadius;
  final double progress;
  final Color tint;
  final int direction;

  const _GlitchSliceOverlay({
    required this.size,
    required this.borderRadius,
    required this.progress,
    required this.tint,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0.01) {
      return const SizedBox.shrink();
    }

    final slices = <double>[
      size * 0.16,
      size * 0.34,
      size * 0.58,
    ];

    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < slices.length; index++)
                Positioned(
                  top: slices[index],
                  left: 0,
                  right: 0,
                  height: size * 0.12,
                  child: Transform.translate(
                    offset: Offset(
                      direction *
                          (progress * (8 - (index * 2))) *
                          math.sin((index + 1) * 1.4),
                      0,
                    ),
                    child: Opacity(
                      opacity: progress * (0.28 - (index * 0.05)),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: McLogo(
                            size: size,
                            borderRadius: borderRadius,
                            withShadow: false,
                            paddingFactor: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
