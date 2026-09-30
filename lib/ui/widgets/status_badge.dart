import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isUncertain;

  const StatusBadge({
    super.key,
    required this.status,
    this.isUncertain = false,
  });

  @override
  Widget build(BuildContext context) {
        String label;
    IconData icon;

    final theme = Theme.of(context);
    
    if (isUncertain || status == 'needs_review') {
      label = 'Needs Review';
      icon = Icons.error_outline_rounded;
    } else {
      switch (status) {
        case 'pending_ai':
          label = 'Waiting AI';
          icon = Icons.hourglass_empty_rounded;
          break;
        case 'processing':
          label = 'Processing...';
          icon = Icons.auto_awesome_rounded;
          break;
        case 'failed':
          label = 'AI Failed';
          icon = Icons.cancel_outlined;
          break;
        case 'completed':
        default:
          label = 'Saved';
          icon = Icons.check_circle_rounded;
          break;
      }
    }

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
      ),
    );
  }
}
