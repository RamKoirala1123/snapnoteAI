import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../../core/app_typography.dart';
import '../widgets/k_components.dart';

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

    return KScaffold(
      title: 'Reminders',
      subtitle: '${reminders.length} Reminders',
      body: reminders.isEmpty
          ? Center(child: Text('No reminders active.', style: context.bodyMedium.muted(context)))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final item = reminders[index];
                final timeStr = item.time != null && item.time!.isNotEmpty ? item.time! : 'Anytime';
                final dateStr = item.dueDate ?? item.date ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: KContainer(
                    onTap: () => onItemTap(item),
                    child: Row(
                      children: [
                        // Left Time Block
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.alarm, color: theme.colorScheme.secondary, size: 20),
                                const SizedBox(height: 2),
                                Text(
                                  timeStr,
                                  style: context.labelMedium.colored(theme.colorScheme.secondary).copyWith(fontWeight: FontWeight.bold),
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
                                      style: context.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  KButton.icon(
                                    icon: Icon(Icons.delete_outline, color: theme.iconTheme.color?.withValues(alpha: 0.5), size: 18),
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
                                    Icon(Icons.calendar_today, size: 12, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                                    const SizedBox(width: 4),
                                    Text(dateStr, style: context.labelMedium.muted(context)),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                item.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.labelSmall.muted(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
