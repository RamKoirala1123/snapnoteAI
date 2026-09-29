import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/capture_card.dart';

class DashboardView extends StatelessWidget {
  final List<CaptureItem> captures;
  final VoidCallback onQuickCapture;
  final Function(String viewName) onNavigateToView;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const DashboardView({
    super.key,
    required this.captures,
    required this.onQuickCapture,
    required this.onNavigateToView,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute stats
    final inboxCount = captures.where((e) => e.status != 'completed' || e.isUncertain).length;
    final eventsCount = captures.where((e) => e.category == AppConstants.catEvent).length;
    final pendingReminders = captures.where((e) => e.category == AppConstants.catReminder && !e.isCompleted).length;
    final openTasks = captures.where((e) => e.category == AppConstants.catTask && !e.isCompleted).length;
    final unreadReadLater = captures.where((e) => e.category == AppConstants.catReadLater && !e.isRead).length;

    final recentCaptures = captures.take(6).toList();
    final upcomingEvents = captures.where((e) => e.category == AppConstants.catEvent || e.category == AppConstants.catReminder).take(4).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header & Quick Capture Hero Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'SnapNote AI',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Anything you see on screen becomes structured notes, events, reminders & tasks.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: onQuickCapture,
                          icon: const Icon(Icons.crop_free_rounded, color: Colors.black),
                          label: const Text(
                            'Capture Screen (Ctrl + Shift + Space)',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Grid Row
            Row(
              children: [
                _statCard(
                  context,
                  title: 'Inbox / Review',
                  count: inboxCount.toString(),
                  icon: Icons.inbox_rounded,
                  color: Colors.amber,
                  onTap: () => onNavigateToView('inbox'),
                ),
                const SizedBox(width: 14),
                _statCard(
                  context,
                  title: 'Events',
                  count: eventsCount.toString(),
                  icon: Icons.calendar_today_rounded,
                  color: Colors.pinkAccent,
                  onTap: () => onNavigateToView('events'),
                ),
                const SizedBox(width: 14),
                _statCard(
                  context,
                  title: 'Pending Reminders',
                  count: pendingReminders.toString(),
                  icon: Icons.alarm_rounded,
                  color: Colors.orangeAccent,
                  onTap: () => onNavigateToView('reminders'),
                ),
                const SizedBox(width: 14),
                _statCard(
                  context,
                  title: 'Open Tasks',
                  count: openTasks.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => onNavigateToView('tasks'),
                ),
                const SizedBox(width: 14),
                _statCard(
                  context,
                  title: 'Unread Articles',
                  count: unreadReadLater.toString(),
                  icon: Icons.menu_book_rounded,
                  color: Colors.lightBlueAccent,
                  onTap: () => onNavigateToView('read_later'),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Two Column Section: Recent Feed & Upcoming Schedule
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Recent Captures Feed
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Captures', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () => onNavigateToView('timeline'),
                            child: const Text('View Timeline →'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (recentCaptures.isEmpty)
                        _emptyBox('No captures yet. Press Ctrl + Shift + Space to capture your screen!')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentCaptures.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = recentCaptures[index];
                            return CaptureCard(
                              item: item,
                              onTap: () => onItemTap(item),
                              onDelete: () => onItemDelete(item.id),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Column 2: Upcoming Events & Reminders
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Upcoming Events & Schedule', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (upcomingEvents.isEmpty)
                        _emptyBox('No upcoming events or reminders.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: upcomingEvents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = upcomingEvents[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.category == AppConstants.catEvent ? Icons.event : Icons.alarm,
                                    color: item.category == AppConstants.catEvent ? Colors.pinkAccent : Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        if (item.date != null || item.time != null)
                                          Text(
                                            '${item.date ?? ''} ${item.time ?? ''}'.trim(),
                                            style: const TextStyle(fontSize: 11, color: Colors.cyan),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded, size: 18),
                                    onPressed: () => onItemTap(item),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12), // Slightly reduced padding to give more room
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      count,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    );
  }
}
