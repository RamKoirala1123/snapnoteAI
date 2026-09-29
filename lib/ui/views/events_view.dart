import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';

class EventsView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const EventsView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = captures.where((e) => e.category == AppConstants.catEvent).toList();
    
    // Sort events by date if available
    events.sort((a, b) {
      final dateA = a.date ?? '';
      final dateB = b.date ?? '';
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
                Icon(Icons.calendar_today_rounded, color: AppConstants.getCategoryColor(AppConstants.catEvent), size: 28),
                const SizedBox(width: 10),
                Text('Events & Schedule', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${events.length} Events', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: events.isEmpty
                  ? const Center(child: Text('No events detected in screenshots.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final item = events[index];
                        return _buildEventCard(item, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(CaptureItem item, ThemeData theme) {
    final dateStr = item.date ?? 'No Date';
    final timeStr = item.time ?? 'All Day';
    final locationStr = item.location ?? item.address ?? item.city ?? '';
    
    // Try to extract just the day/month for a calendar-like block
    String day = '00';
    String month = '???';
    try {
      if (dateStr.isNotEmpty && dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length >= 3) {
          day = parts[2];
          final mInt = int.tryParse(parts[1]);
          if (mInt != null && mInt >= 1 && mInt <= 12) {
            const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
            month = months[mInt - 1];
          }
        }
      }
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onItemTap(item),
        child: Row(
          children: [
            // Left Calendar Block
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Middle Details
            Expanded(
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(timeStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        
                        if (locationStr.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationStr,
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.summary.isNotEmpty ? item.summary : item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
