import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';

enum DuplicateAction { openExisting, saveAnyway, deleteNew }

class DuplicateAlertDialog extends StatelessWidget {
  final CaptureItem newItem;
  final CaptureItem existingItem;

  const DuplicateAlertDialog({
    super.key,
    required this.newItem,
    required this.existingItem,
  });

  static Future<DuplicateAction?> show(
    BuildContext context, {
    required CaptureItem newItem,
    required CaptureItem existingItem,
  }) {
    return showDialog<DuplicateAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DuplicateAlertDialog(
        newItem: newItem,
        existingItem: existingItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.copy_rounded, color: Colors.amber),
          const SizedBox(width: 8),
          const Text('Possible Duplicate Detected'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This new capture looks very similar to an item already in your knowledge base:',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existingItem.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  existingItem.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('What would you like to do?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(DuplicateAction.deleteNew),
          child: const Text('Delete New', style: TextStyle(color: Colors.redAccent)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(DuplicateAction.openExisting),
          child: const Text('Open Existing'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(DuplicateAction.saveAnyway),
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          child: const Text('Save Anyway'),
        ),
      ],
    );
  }
}
