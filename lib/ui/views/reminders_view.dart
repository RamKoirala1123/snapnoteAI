import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';

class RemindersView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const RemindersView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminders = captures.where((e) => e.category == AppConstants.catReminder).toList();
    
    // Sort by due date/time if available, else creation date
    reminders.sort((a, b) {
      final dateA = a.dueDate ?? a.date ?? '';
      final dateB = b.dueDate ?? b.date ?? '';
      if (dateA.isNotEmpty && dateB.isNotEmpty) {
        return dateA.compareTo(dateB);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.alarm_rounded, color: AppConstants.getCategoryColor(AppConstants.catReminder), size: 28),
                const SizedBox(width: 10),
                Text('Reminders', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${reminders.length} Reminders', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: reminders.isEmpty
                  ? const Center(child: Text('No reminders active.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final item = reminders[index];
                        final timeStr = item.time != null && item.time!.isNotEmpty ? item.time! : 'Anytime';
                        final dateStr = item.dueDate ?? item.date ?? '';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.3)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => onItemTap(item),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Left Time Block
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.alarm, color: theme.colorScheme.secondary),
                                          const SizedBox(height: 4),
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: theme.colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Right Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () => onItemDelete(item.id),
                                            ),
                                          ],
                                        ),
                                        if (dateStr.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(dateStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          item.summary,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
