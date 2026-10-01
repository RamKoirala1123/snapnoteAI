import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/k_components.dart';

class NotesView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const NotesView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = captures.where((e) => e.category == AppConstants.catNote).toList();
    
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return KScaffold(
      backgroundColor: Colors.transparent,
      title: 'Notes & Documentation',
      subtitle: '${notes.length} Notes',
      body: notes.isEmpty
                  ? const Center(child: Text('No notes captured yet.', style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final item = notes[index];
                        return _buildNoteCard(item, theme);
                      },
                    ),
    );
  }

  Widget _buildNoteCard(CaptureItem item, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      color: theme.brightness == Brightness.dark 
          ? Colors.blue.withValues(alpha: 0.05) 
          : Colors.blue.withValues(alpha: 0.05),
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
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  KButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onItemDelete(item.id),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Text(
                  item.summary.isNotEmpty ? item.summary : item.content,
                  style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
