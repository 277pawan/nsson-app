import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const CartScreen({super.key, this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: AppStrings.emptyCart,
            subtitle: AppStrings.emptyCartSub,
            actionLabel: AppStrings.startShopping,
            onAction: onStartShopping,
          );
        }

        return Column(
          children: [
            // Cart Items
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                itemBuilder: (context, idx) {
                  final item = cart.items[idx];
                  return StaggerAnimation(
                    index: idx,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.image,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 72,
                                height: 72,
                                color: AppColors.borderLight,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rs ${item.price} / unit',
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Quantity controls
                                Row(
                                  children: [
                                    _QuantityControl(
                                      quantity: item.quantity,
                                      onDecrement: () async {
                                        final success =
                                            await cart.decrement(item.productId);
                                        if (!context.mounted || success) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              cart.error ??
                                                  'Unable to update cart.',
                                            ),
                                          ),
                                        );
                                      },
                                      onIncrement: () async {
                                        final success =
                                            await cart.increment(item.productId);
                                        if (!context.mounted || success) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              cart.error ??
                                                  'Unable to update cart.',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Rs ${item.price * item.quantity}',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Delete
                          IconButton(
                            onPressed: () async {
                              final success =
                                  await cart.removeFromCart(item.productId);
                              if (!context.mounted || success) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    cart.error ??
                                        'Unable to remove item from cart.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger, size: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Secure badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14, color: AppColors.success),
                        SizedBox(width: 6),
                        Text(
                          AppStrings.secureTx,
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _summaryRow(AppStrings.subtotal, 'Rs ${cart.subtotal}'),
                  const SizedBox(height: 6),
                  _summaryRow(
                    AppStrings.shipping,
                    AppStrings.free,
                    valueColor: AppColors.success,
                  ),
                  const Divider(height: 20),
                  _summaryRow(
                    AppStrings.total,
                    'Rs ${cart.total.toStringAsFixed(0)}',
                    isBold: true,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.checkout),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            fontSize: fontSize,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ??
                (isBold ? AppColors.primary : AppColors.textPrimary),
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(9)),
            child: const SizedBox(
              width: 32,
              height: 32,
              child:
                  Icon(Icons.remove, size: 16, color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          InkWell(
            onTap: onIncrement,
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(9)),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.add, size: 16, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
