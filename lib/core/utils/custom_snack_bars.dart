import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism SnackBar helper for premium, frosted notifications.
/// - Transparent SnackBar to allow blur to show through
/// - Floating behavior, zero padding, custom content with blur & border
/// - Optional action styled as a TextButton inside the glass container
class CustomSnackBars {
  static void showGlassSnackBar({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 8),
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Ensure no lingering snackbars
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        duration: duration,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.50),
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (actionLabel != null && onAction != null)
                    TextButton(
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        onAction();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      child: Text(actionLabel.toUpperCase()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
