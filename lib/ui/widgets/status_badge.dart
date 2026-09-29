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
    Color color;
    String label;
    IconData icon;

    if (isUncertain || status == 'needs_review') {
      color = Colors.amber;
      label = '⚠️ Needs Review';
      icon = Icons.error_outline_rounded;
    } else {
      switch (status) {
        case 'pending_ai':
          color = Colors.blue;
          label = '⏳ Waiting AI';
          icon = Icons.hourglass_empty_rounded;
          break;
        case 'processing':
          color = Colors.purple;
          label = '⚡ Processing...';
          icon = Icons.auto_awesome_rounded;
          break;
        case 'failed':
          color = Colors.redAccent;
          label = '❌ AI Failed';
          icon = Icons.cancel_outlined;
          break;
        case 'completed':
        default:
          color = const Color(0xFF10B981);
          label = '✓ Saved';
          icon = Icons.check_circle_rounded;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
