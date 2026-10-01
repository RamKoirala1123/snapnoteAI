import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../widgets/capture_card.dart';
import '../widgets/k_components.dart';

class TagsView extends StatefulWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const TagsView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute tag counts
    final Map<String, int> tagCounts = {};
    for (var capture in widget.captures) {
      for (var tag in capture.tags) {
        final clean = tag.trim().toLowerCase();
        if (clean.isNotEmpty) {
          tagCounts[clean] = (tagCounts[clean] ?? 0) + 1;
        }
      }
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final filteredCaptures = _selectedTag == null
        ? widget.captures
        : widget.captures.where((e) => e.tags.any((t) => t.trim().toLowerCase() == _selectedTag)).toList();

    return KScaffold(
      backgroundColor: Colors.transparent,
      title: 'Tag Manager & Filter',
      subtitle: 'Organize by tags',
      trailing: _selectedTag != null
          ? KButton.textIcon(
              onPressed: () => setState(() => _selectedTag = null),
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Filter'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Tag Cloud Card
            if (sortedTags.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Knowledge Tags',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sortedTags.map((entry) {
                            final tag = entry.key;
                            final count = entry.value;
                            final isSelected = _selectedTag == tag;

                            return ChoiceChip(
                              label: Text('#$tag ($count)'),
                              selected: isSelected,
                              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                              onSelected: (val) {
                                setState(() => _selectedTag = val ? tag : null);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Filtered List Header
            Text(
              _selectedTag == null ? 'All Captures (${filteredCaptures.length})' : 'Captures tagged #$_selectedTag (${filteredCaptures.length})',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredCaptures.isEmpty
                  ? const Center(child: Text('No captures found with this tag.', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: filteredCaptures.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filteredCaptures[index];
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
