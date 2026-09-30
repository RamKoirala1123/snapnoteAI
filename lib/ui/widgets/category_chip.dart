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
    final theme = Theme.of(context);
    final icon = AppConstants.getCategoryIcon(category);
    final label = AppConstants.getCategoryLabel(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
