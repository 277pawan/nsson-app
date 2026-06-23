import 'package:flutter/material.dart';
import 'custom_snack_bars.dart';

/// Centralized helper for showing "Added to Cart" SnackBar notifications.
/// Now uses the glassmorphism style and enforces strict duration/cleanup.
void showCartNotification(
  BuildContext context, {
  required String productName,
  int quantity = 1,
}) {
  CustomSnackBars.showGlassSnackBar(
    context: context,
    message: '$quantity × $productName added to cart',
    actionLabel: 'View Cart',
    duration: const Duration(seconds: 8),
    onAction: () => Navigator.of(context).pushNamed('/cart'),
  );
}
