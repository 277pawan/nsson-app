import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Stagger-in animation for list items. Fades in + slides up.
class StaggerAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final int baseDelayMs;
  final int incrementMs;

  const StaggerAnimation({
    super.key,
    required this.index,
    required this.child,
    this.baseDelayMs = 380,
    this.incrementMs = 50,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          Duration(milliseconds: baseDelayMs + min(index * incrementMs, 250)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, (1 - value) * 18),
        child: Opacity(opacity: value, child: child),
      ),
      child: child,
    );
  }
}

/// Fade-in animation wrapper
class FadeIn extends StatelessWidget {
  final Widget child;
  final int durationMs;
  final double slideOffset;

  const FadeIn({
    super.key,
    required this.child,
    this.durationMs = 500,
    this.slideOffset = 20,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, (1 - value) * slideOffset),
        child: Opacity(opacity: value, child: child),
      ),
      child: child,
    );
  }
}

/// Scale-in animation (for success checkmarks etc.)
class ScaleIn extends StatelessWidget {
  final Widget child;
  final int durationMs;

  const ScaleIn({
    super.key,
    required this.child,
    this.durationMs = 600,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: child,
    );
  }
}

/// Slide-in from the left or right (useful for page-level transitions)
class SlideIn extends StatelessWidget {
  final Widget child;
  final int durationMs;
  final bool fromRight;

  const SlideIn({
    super.key,
    required this.child,
    this.durationMs = 500,
    this.fromRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset((1 - value) * (fromRight ? 60 : -60), 0),
        child: Opacity(opacity: value.clamp(0, 1), child: child),
      ),
      child: child,
    );
  }
}

/// Continuously pulsing scale animation — great for badges, "Pay" buttons, etc.
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final int durationMs;

  const PulseAnimation({
    super.key,
    required this.child,
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.durationMs = 900,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// Bounce-in animation (elastic, good for icons/checkmarks)
class BounceIn extends StatelessWidget {
  final Widget child;
  final int durationMs;

  const BounceIn({
    super.key,
    required this.child,
    this.durationMs = 700,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.bounceOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Opacity(opacity: value.clamp(0, 1), child: child),
      ),
      child: child,
    );
  }
}

/// Shimmer skeleton box for loading states — matches Moto Crafter's color palette.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A full shimmer card skeleton matching the product card layout.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  Container(
                      height: 12, width: 120, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  Container(
                      height: 14, width: 80, color: const Color(0xFFE2E8F0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a single notification card.
class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                            height: 13, color: const Color(0xFFE2E8F0)),
                      ),
                      const SizedBox(width: 40),
                      Container(
                          width: 48,
                          height: 11,
                          color: const Color(0xFFE2E8F0)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(height: 11, color: const Color(0xFFE2E8F0)),
                  const SizedBox(height: 5),
                  Container(
                      height: 11, width: 180, color: const Color(0xFFE2E8F0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Page-level skeleton screens
// ═══════════════════════════════════════════════════════════════

/// Shimmer banner carousel placeholder (180 h, rounded 22).
class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }
}

/// Shimmer 2×2 highlight-chips grid (Genuine / Best Prices / Top Rated / Easy Returns).
class HighlightsSkeleton extends StatelessWidget {
  const HighlightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Shimmer horizontal brand row (5 cards × 88 w × 100 h).
class BrandRowSkeleton extends StatelessWidget {
  const BrandRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => Container(
            width: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer 2-column product grid (matches ProductCard 0.62 aspect ratio).
class ProductGridSkeleton extends StatelessWidget {
  final int count;
  const ProductGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Shimmer card that mirrors the order card layout
/// (badge row + date + 2 item rows + divider + total row).
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + badge
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ))),
                const SizedBox(width: 12),
                Container(
                    width: 72,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            // Date row
            Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                )),
            const SizedBox(height: 14),
            // Item rows
            for (int i = 0; i < 2; i++) ...[
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFFE2E8F0), shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ))),
                  const SizedBox(width: 16),
                  Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      )),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 20, color: Color(0xFFE2E8F0)),
            // Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    )),
                Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Stacked list of [count] order card skeletons with a heading stub.
class OrdersListSkeleton extends StatelessWidget {
  final int count;
  const OrdersListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        // "My Orders" heading stub
        Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: const Color(0xFFF8FAFC),
          child: Container(
            width: 140,
            height: 20,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        for (int i = 0; i < count; i++) const OrderCardSkeleton(),
      ],
    );
  }
}

/// Full home-screen skeleton: banner + highlights + brands row + product grid.
/// Drop-in while [ProductProvider.loading] is true.
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const pad = 16.0;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(pad, 14, pad, pad),
      children: const [
        BannerSkeleton(),
        SizedBox(height: 16),
        HighlightsSkeleton(),
        SizedBox(height: 20),
        // Section header stubs
        _SectionHeaderSkeleton(),
        SizedBox(height: 10),
        BrandRowSkeleton(),
        SizedBox(height: 20),
        _SectionHeaderSkeleton(),
        SizedBox(height: 10),
        ProductGridSkeleton(),
      ],
    );
  }
}

/// Minimal shimmer stub for a SectionHeader row (title + "View all" link).
class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              )),
          Container(
              width: 60,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              )),
        ],
      ),
    );
  }
}

/// Product-listing page skeleton: search-bar stub + product grid.
class ProductListingSkeleton extends StatelessWidget {
  const ProductListingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar stub
        Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: const Color(0xFFF8FAFC),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ProductGridSkeleton(count: 8),
      ],
    );
  }
}
