import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum McBadgeVariant { success, warning, danger, info, neutral }

class McBadge extends StatelessWidget {
  final String label;
  final McBadgeVariant variant;
  final double fontSize;

  const McBadge({
    super.key,
    required this.label,
    this.variant = McBadgeVariant.neutral,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg, borderColor;

    switch (variant) {
      case McBadgeVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        borderColor = AppColors.successLight;
        break;
      case McBadgeVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        borderColor = AppColors.warningLight;
        break;
      case McBadgeVariant.danger:
        bg = AppColors.dangerLight;
        fg = AppColors.dangerDark;
        borderColor = AppColors.dangerLight;
        break;
      case McBadgeVariant.info:
        bg = AppColors.primaryBg;
        fg = AppColors.info;
        borderColor = AppColors.primaryLight;
        break;
      case McBadgeVariant.neutral:
        bg = AppColors.borderLight;
        fg = AppColors.textSecondary;
        borderColor = AppColors.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }

  /// Get the right variant for order status (case-insensitive).
  static McBadgeVariant statusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'processing':
        return McBadgeVariant.warning;
      case 'shipped':
        return McBadgeVariant.info;
      case 'delivered':
        return McBadgeVariant.success;
      case 'cancelled':
        return McBadgeVariant.danger;
      case 'pending':
        return McBadgeVariant.neutral;
      default:
        return McBadgeVariant.neutral;
    }
  }
}
