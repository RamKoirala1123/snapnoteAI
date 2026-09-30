import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../../core/app_typography.dart';
import '../widgets/k_components.dart';

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

    return KScaffold(
      title: 'Events & Schedule',
      subtitle: '${events.length} Events',
      body: events.isEmpty
          ? Center(child: Text('No events detected in screenshots.', style: context.bodyMedium.muted(context)))
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final item = events[index];
                return _buildEventCard(context, item, theme);
              },
            ),
    );
  }

  Widget _buildEventCard(BuildContext context, CaptureItem item, ThemeData theme) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KContainer(
        padding: EdgeInsets.zero,
        onTap: () => onItemTap(item),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Calendar Block
              Container(
                width: 70,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month,
                      style: context.labelMedium.primary(context).copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day,
                      style: context.headlineSmall.primary(context).copyWith(fontSize: 24),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: context.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          KButton.icon(
                            icon: Icon(Icons.delete_outline, color: theme.iconTheme.color?.withValues(alpha: 0.5), size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => onItemDelete(item.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(timeStr, style: context.labelMedium),
                          
                          if (locationStr.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on_rounded, size: 14, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationStr,
                                style: context.labelMedium,
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
                        style: context.labelSmall.muted(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
