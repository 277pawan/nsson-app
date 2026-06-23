import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/brand_logo_image.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/utils/cart_notification.dart';
import '../../core/utils/responsive.dart';
import '../../data/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCategories;
  final VoidCallback? onNavigateToProducts;

  const HomeScreen({
    super.key,
    this.onNavigateToCategories,
    this.onNavigateToProducts,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final banners = context.read<ProductProvider>().banners;
      if (banners.isEmpty) return;
      final count = banners.length;
      final next = (_bannerIndex + 1) % count;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.getPadding(context);
    final productProv = context.watch<ProductProvider>();
    // Show full-page skeleton on very first load
    if (productProv.loading &&
        productProv.products.isEmpty &&
        productProv.brands.isEmpty) {
      return const HomeScreenSkeleton();
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ProductProvider>().refreshAll(),
      child: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(padding, 14, padding, padding),
        children: [
          // Banner Carousel
          _buildBanner(),
          const SizedBox(height: 16),

          // Highlights
          _buildHighlights(),
          const SizedBox(height: 20),

          // Featured Brands
          SectionHeader(
            title: AppStrings.featuredBrands,
            onViewAll: widget.onNavigateToCategories,
          ),
          const SizedBox(height: 10),
          _buildBrands(),
          const SizedBox(height: 20),

          // Featured Products
          SectionHeader(
            title: AppStrings.featuredProducts,
            onViewAll: widget.onNavigateToProducts,
          ),
          const SizedBox(height: 10),
          _buildProducts(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    final banners = context.watch<ProductProvider>().banners;
    if (banners.isEmpty) {
      return SizedBox(
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/banner-compress.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.borderLight),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.45),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Live catalog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Promotions will appear here once banners are published in admin.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            PageView.builder(
              controller: _bannerController,
              onPageChanged: (idx) => setState(() => _bannerIndex = idx),
              itemCount: banners.length,
              itemBuilder: (context, idx) {
                final banner = banners[idx];
                return _BannerCard(banner: banner);
              },
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _bannerController,
                  count: banners.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 8,
                    expansionFactor: 3,
                    dotColor: Colors.white38,
                    activeDotColor: Colors.white,
                    spacing: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    final items = [
      {
        't': AppStrings.genuine,
        'i': Icons.verified_user_outlined,
        'c': AppColors.genuineTint
      },
      {
        't': AppStrings.bestPrices,
        'i': Icons.trending_up,
        'c': AppColors.priceTint
      },
      {
        't': AppStrings.topRated,
        'i': Icons.star_outline,
        'c': AppColors.ratedTint
      },
      {
        't': AppStrings.easyReturns,
        'i': Icons.replay_outlined,
        'c': AppColors.returnTint
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, idx) {
        final it = items[idx];
        return StaggerAnimation(
          index: idx,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: it['c'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(it['i'] as IconData,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    it['t'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrands() {
    final prov = context.watch<ProductProvider>();
    final brands = prov.brands;
    if (prov.loading && brands.isEmpty) {
      return const BrandRowSkeleton();
    }
    if (brands.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No brands published yet',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, idx) {
          final brand = brands[idx];
          return StaggerAnimation(
            index: idx,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/products',
                    arguments: {'brand': brand.name});
              },
              child: Container(
                width: 88,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BrandLogoImage(
                      logo: brand.logo,
                      width: 42,
                      height: 42,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      brand.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProducts() {
    final productProv = context.watch<ProductProvider>();
    final products = productProv.products;
    if (productProv.loading && products.isEmpty) {
      return const ProductGridSkeleton();
    }
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No products are available right now.',
            style: TextStyle(color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, idx) {
        final product = products[idx];
        return StaggerAnimation(
          index: idx,
          child: ProductCard(
            product: product,
            onTap: () => Navigator.pushNamed(context, '/product-detail',
                arguments: product),
            onAddToCart: () async {
              final success =
                  await context.read<CartProvider>().addToCart(product);
              if (!context.mounted) return;
              if (success) {
                showCartNotification(
                  context,
                  productName: product.name,
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.read<CartProvider>().error ??
                        'Unable to add item to cart.',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final PromoBanner banner;

  const _BannerCard({required this.banner});

  Future<void> _openProduct(BuildContext context, String productId) async {
    final product = await context.read<ProductProvider>().fetchProductById(productId);
    if (product == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open product.')),
        );
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/product-detail', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: banner.productId != null && banner.productId!.isNotEmpty
          ? () => _openProduct(context, banner.productId!)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
        // If the banner has a network image URL, show it; otherwise fall back to local asset
        banner.image.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: banner.image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.borderLight),
                errorWidget: (_, __, ___) => Image.asset(
                  'assets/banner-compress.jpg',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/banner-compress.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.borderLight),
              ),
        // Subtle bottom gradient only – keeps text readable without hiding the image
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (banner.title.isNotEmpty)
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              if (banner.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 13,
                    shadows: const [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
  }
}
