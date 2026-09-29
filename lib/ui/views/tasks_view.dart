import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';

class TasksView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;
  final Function(CaptureItem item)? onItemUpdate;

  const TasksView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
    this.onItemUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = captures.where((e) => e.category == AppConstants.catTask).toList();
    
    // Sort by created date descending
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final openTasks = tasks.where((e) => !e.isCompleted).toList();
    final completedTasks = tasks.where((e) => e.isCompleted).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppConstants.getCategoryColor(AppConstants.catTask), size: 28),
                const SizedBox(width: 10),
                Text('Actionable Tasks', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${tasks.length} Total', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('No tasks found.', style: TextStyle(color: Colors.grey)))
                  : ListView(
                      children: [
                        if (openTasks.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('To Do (${openTasks.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...openTasks.map((item) => _buildTaskCard(item, theme)),
                          const SizedBox(height: 16),
                        ],
                        if (completedTasks.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 8),
                            child: Text('Completed (${completedTasks.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...completedTasks.map((item) => _buildTaskCard(item, theme)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(CaptureItem item, ThemeData theme) {
    final isDone = item.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: isDone,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              if (onItemUpdate != null) {
                onItemUpdate!(item.copyWith(isCompleted: val ?? false));
              }
            },
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : null,
          ),
        ),
        subtitle: item.summary.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            item.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.dueDate != null) ...[
              const Icon(Icons.event, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.dueDate!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 16),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => onItemDelete(item.id),
              tooltip: 'Delete Task',
            ),
          ],
        ),
        onTap: () => onItemTap(item),
      ),
    );
  }
}

