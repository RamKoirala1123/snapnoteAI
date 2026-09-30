import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/capture_item.dart';
import '../widgets/capture_card.dart';
import '../widgets/k_components.dart';

class TimelineView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const TimelineView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group captures chronologically by day string (e.g. "September 29, 2026")
    final Map<String, List<CaptureItem>> grouped = {};
    for (var capture in captures) {
      final dayKey = DateFormat('EEEE, MMMM d, yyyy').format(capture.createdAt);
      grouped.putIfAbsent(dayKey, () => []).add(capture);
    }

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline_rounded, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 10),
                Text('Visual Timeline', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${captures.length} Total Memory Captures', style: const TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: grouped.isEmpty
                  ? const Center(child: Text('Timeline is empty.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final dateHeader = grouped.keys.elementAt(index);
                        final dayItems = grouped[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    dateHeader,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Divider(color: theme.dividerColor)),
                                ],
                              ),
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, itemIndex) {
                                final item = dayItems[itemIndex];
                                return CaptureCard(
                                  item: item,
                                  onTap: () => onItemTap(item),
                                  onDelete: () => onItemDelete(item.id),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
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
