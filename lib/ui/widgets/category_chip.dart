import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool showLabel;

  const CategoryChip({
    super.key,
    required this.category,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getCategoryColor(category);
    final icon = AppConstants.getCategoryIcon(category);
    final label = AppConstants.getCategoryLabel(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
