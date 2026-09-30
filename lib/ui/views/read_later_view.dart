import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/k_components.dart';

class ReadLaterView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;
  final Function(CaptureItem item)? onItemUpdate;

  const ReadLaterView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
    this.onItemUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = captures.where((e) => e.category == AppConstants.catReadLater).toList();
    
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final unread = items.where((e) => !e.isRead).toList();
    final read = items.where((e) => e.isRead).toList();

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_rounded, color: AppConstants.getCategoryColor(AppConstants.catReadLater), size: 28),
                const SizedBox(width: 10),
                Text('Read Later', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${items.length} Articles', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No articles saved.', style: TextStyle(color: Colors.grey)))
                  : ListView(
                      children: [
                        if (unread.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Unread (${unread.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...unread.map((item) => _buildArticleCard(item, theme)),
                          const SizedBox(height: 16),
                        ],
                        if (read.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 8),
                            child: Text('Finished (${read.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                          ...read.map((item) => _buildArticleCard(item, theme)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(CaptureItem item, ThemeData theme) {
    final isRead = item.isRead;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onItemTap(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Block
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isRead ? Icons.check_circle : Icons.article, color: theme.colorScheme.tertiary, size: 24),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isRead ? Colors.grey : null,
                              decoration: isRead ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        KButton.icon(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onItemDelete(item.id),
                        ),
                      ],
                    ),
                    if (item.url != null && item.url!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.link, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.url!,
                              style: const TextStyle(fontSize: 13, color: Colors.blue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13, 
                        color: isRead ? Colors.grey : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionChip(
                      avatar: Icon(isRead ? Icons.undo : Icons.check, size: 16),
                      label: Text(isRead ? 'Mark Unread' : 'Mark Read', style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        if (onItemUpdate != null) {
                          onItemUpdate!(item.copyWith(isRead: !isRead));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
