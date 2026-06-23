import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/mc_badge.dart';
import '../../core/widgets/animations.dart';
import '../../data/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../core/utils/cart_notification.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImageIndex = 0;
  late final PageController _imagePageController;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  Color get _stockColor {
    if (widget.product.stock == 0) return AppColors.danger;
    if (widget.product.stock <= 50) return AppColors.warning;
    return AppColors.success;
  }

  String get _stockText {
    if (widget.product.stock == 0) return AppStrings.outOfStock;
    if (widget.product.stock <= 50) {
      return '${AppStrings.lowStock} (${widget.product.stock} left)';
    }
    return '${AppStrings.inStock} (${widget.product.stock} units)';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildStickyBottomBar(product),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with image carousel
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image carousel
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: product.allImages.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0
                            ? 'product_${product.id}'
                            : 'product_${product.id}_$index',
                        child: CachedNetworkImage(
                          imageUrl: product.allImages[index],
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.borderLight),
                        ),
                      );
                    },
                  ),
                  // Image counter badge
                  if (product.allImages.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _imagePageController,
                          count: product.allImages.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColors.primary,
                            dotColor: Colors.white.withOpacity(0.6),
                            spacing: 6,
                          ),
                        ),
                      ),
                    ),
                  // Image count label
                  if (product.allImages.length > 1)
                    Positioned(
                      top: 80,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${product.allImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeIn(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail strip
                      if (product.allImages.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: product.allImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final isActive = _currentImageIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    _imagePageController.animateToPage(
                                      index,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isActive
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: isActive ? 2 : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: product.allImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                      // Brand + Category badges
                      Row(
                        children: [
                          McBadge(
                            label: context
                                .read<ProductProvider>()
                                .brandName(product.brand),
                            variant: McBadgeVariant.info,
                          ),
                          const SizedBox(width: 8),
                          McBadge(
                            label: context
                                .read<ProductProvider>()
                                .categoryName(product.category),
                            variant: McBadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Part number
                      Text(
                        'Part: ${product.partNumber}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Text(
                        'Rs ${product.price}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stock indicator
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _stockColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _stockText,
                            style: TextStyle(
                              color: _stockColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Divider(),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        AppStrings.description,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Divider(),
                      const SizedBox(height: 16),

                      // Trust badges
                      _buildTrustBadges(),

                      const SizedBox(height: 24),

                      // Quantity selector
                      Row(
                        children: [
                          const Text(
                            AppStrings.quantity,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _quantityButton(
                                  Icons.remove,
                                  () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    '$_quantity',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _quantityButton(
                                  Icons.add,
                                  () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(Product product) {
    final isInStock = product.stock > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Add to Cart button (outlined)
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: isInStock
                      ? () async {
                          final success = await context
                              .read<CartProvider>()
                              .addToCart(product, quantity: _quantity);
                          if (!context.mounted) return;
                          if (success) {
                            showCartNotification(
                              context,
                              productName: product.name,
                              quantity: _quantity,
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
                        }
                      : null,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text('Add to Cart'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy Now button (filled)
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: isInStock
                      ? () async {
                          final success = await context
                              .read<CartProvider>()
                              .addToCart(product, quantity: _quantity);
                          if (!context.mounted) return;
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.read<CartProvider>().error ??
                                      'Unable to continue to checkout.',
                                ),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          Navigator.of(context).pushNamed('/checkout');
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  child: Text('Buy at Rs ${product.price * _quantity}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTrustBadges() {
    final badges = [
      {
        'i': Icons.verified_outlined,
        't': '100% Genuine',
        'c': AppColors.success
      },
      {
        'i': Icons.local_shipping_outlined,
        't': 'Fast Delivery',
        'c': AppColors.primary
      },
      {'i': Icons.replay_outlined, 't': 'Easy Returns', 'c': AppColors.warning},
    ];

    return Row(
      children: badges.map((b) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: (b['c'] as Color).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(b['i'] as IconData, color: b['c'] as Color, size: 22),
                const SizedBox(height: 4),
                Text(
                  b['t'] as String,
                  style: TextStyle(
                    color: b['c'] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
