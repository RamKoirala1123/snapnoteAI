import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../widgets/capture_card.dart';
import '../widgets/k_components.dart';

class InboxView extends StatefulWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const InboxView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  bool _filterNeedsReviewOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = widget.captures.where((item) {
      if (_filterNeedsReviewOnly && !item.isUncertain && item.status != 'needs_review') {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
            item.summary.toLowerCase().contains(q) ||
            item.tags.any((t) => t.toLowerCase().contains(q));
      }
      return true;
    }).toList();

    final needsReviewCount = widget.captures.where((e) => e.isUncertain || e.status == 'needs_review').length;

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Filter Toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inbox & Processing',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Recently captured items and items requiring your confirmation',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All Inbox'),
                      selected: !_filterNeedsReviewOnly,
                      onSelected: (val) => setState(() => _filterNeedsReviewOnly = false),
                    ),
                    ChoiceChip(
                      label: Text('⚠️ Needs Review ($needsReviewCount)'),
                      selected: _filterNeedsReviewOnly,
                      selectedColor: Colors.amber.withValues(alpha: 0.3),
                      onSelected: (val) => setState(() => _filterNeedsReviewOnly = true),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              decoration: const InputDecoration(
                hintText: 'Filter inbox items...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 16),

            // Grid / Feed
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: theme.dividerColor),
                          const SizedBox(height: 12),
                          Text(
                            _filterNeedsReviewOnly ? 'No items requiring review!' : 'Inbox is empty.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return CaptureCard(
                          item: item,
                          onTap: () => widget.onItemTap(item),
                          onDelete: () => widget.onItemDelete(item.id),
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
