import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../constants/app_colors.dart';
import '../utils/cart_notification.dart';
import 'app_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E9F3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product_${product.id}',
              child: Stack(
                children: [
                  AppNetworkImage(
                    imageUrl: product.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  if (product.stock <= 50 && product.stock > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'Low Stock',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  if (product.stock == 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context
                  .read<ProductProvider>()
                  .brandName(product.brand)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              product.partNumber,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _PriceDisplay(product: product),
                const Spacer(),
                _QuantitySelector(
                  product: product,
                  onAddToCart: onAddToCart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;

  const _QuantitySelector({
    required this.product,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.getQuantity(product.id);

    if (quantity == 0) {
      return _AddButton(
        product: product,
        onAddToCart: onAddToCart,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              final success =
                  await context.read<CartProvider>().decrement(product.id);
              if (!context.mounted || success) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.read<CartProvider>().error ??
                        'Unable to update cart.',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final success =
                  await context.read<CartProvider>().increment(product.id);
              if (!context.mounted) return;
              if (success) {
                showCartNotification(
                  context,
                  productName: product.name,
                  quantity:
                      context.read<CartProvider>().getQuantity(product.id),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.read<CartProvider>().error ??
                        'Unable to update cart.',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddToCart;

  const _AddButton({
    required this.product,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;

    if (outOfStock) {
      return FilledButton.icon(
        onPressed: null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          disabledBackgroundColor: Colors.grey.shade300,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          minimumSize: const Size(50, 32),
        ),
        icon: const Icon(Icons.block, size: 16),
        label: const Text('Sold'),
      );
    }

    return FilledButton.icon(
      onPressed: onAddToCart ??
          () async {
            final success =
                await context.read<CartProvider>().addToCart(product);
            if (!context.mounted) return;
            if (success) {
              showCartNotification(
                context,
                productName: product.name,
                quantity: 1,
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
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        minimumSize: const Size(50, 32),
      ),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add'),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final Product product;

  const _PriceDisplay({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0 &&
        product.finalPrice > 0 &&
        product.finalPrice < product.price;

    if (hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${product.finalPrice.round()}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '₹${product.price}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return Text(
      '₹${product.price}',
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
