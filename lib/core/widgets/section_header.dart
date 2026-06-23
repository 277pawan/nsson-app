import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Section header with "View All" button
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View All'),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
          ),
      ],
    );
  }
}
