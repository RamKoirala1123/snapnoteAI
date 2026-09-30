import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/k_components.dart';

class IdeasView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const IdeasView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ideas = captures.where((e) => e.category == AppConstants.catIdea).toList();
    
    ideas.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, color: AppConstants.getCategoryColor(AppConstants.catIdea), size: 28),
                const SizedBox(width: 10),
                Text('Ideas & Concepts', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${ideas.length} Ideas', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ideas.isEmpty
                  ? const Center(child: Text('No ideas saved.', style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: ideas.length,
                      itemBuilder: (context, index) {
                        final item = ideas[index];
                        return _buildIdeaCard(item, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaCard(CaptureItem item, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      color: theme.brightness == Brightness.dark 
          ? Colors.amber.withValues(alpha: 0.05) 
          : Colors.amber.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onItemTap(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, size: 20, color: Colors.amber[600]),
                  const Spacer(),
                  KButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onItemDelete(item.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  item.summary,
                  style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                  overflow: TextOverflow.fade,
                ),
              ),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: item.tags.take(2).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('#$tag', style: TextStyle(fontSize: 10, color: Colors.amber[800])),
                  )).toList(),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
