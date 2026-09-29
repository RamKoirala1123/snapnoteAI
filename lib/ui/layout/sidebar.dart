import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';

class Sidebar extends StatelessWidget {
  final String activeView;
  final Function(String view) onSelectView;
  final VoidCallback onQuickCapture;
  final int inboxCount;

  const Sidebar({
    super.key,
    required this.activeView,
    required this.onSelectView,
    required this.onQuickCapture,
    required this.inboxCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // App Title Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Text(
                        'AI Screen Capture',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Quick Capture Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onQuickCapture,
                icon: const Icon(Icons.crop_free_rounded, size: 18),
                label: const Text('Capture Screen', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _navItem(context, id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_rounded),
                _navItem(context, id: 'inbox', label: 'Inbox & Review', icon: Icons.inbox_rounded, badgeCount: inboxCount),
                const Divider(height: 16),
                _navItem(context, id: 'notes', label: 'Notes', icon: AppConstants.getCategoryIcon(AppConstants.catNote)),
                _navItem(context, id: 'events', label: 'Events', icon: AppConstants.getCategoryIcon(AppConstants.catEvent)),
                _navItem(context, id: 'reminders', label: 'Reminders', icon: AppConstants.getCategoryIcon(AppConstants.catReminder)),
                _navItem(context, id: 'tasks', label: 'Tasks', icon: AppConstants.getCategoryIcon(AppConstants.catTask)),
                _navItem(context, id: 'read_later', label: 'Read Later', icon: AppConstants.getCategoryIcon(AppConstants.catReadLater)),
                _navItem(context, id: 'ideas', label: 'Ideas', icon: AppConstants.getCategoryIcon(AppConstants.catIdea)),
                _navItem(context, id: 'shopping', label: 'Shopping', icon: AppConstants.getCategoryIcon(AppConstants.catShopping)),
                _navItem(context, id: 'code', label: 'Code', icon: AppConstants.getCategoryIcon(AppConstants.catCode)),
                _navItem(context, id: 'places', label: 'Places', icon: AppConstants.getCategoryIcon(AppConstants.catPlace)),
                const Divider(height: 16),
                _navItem(context, id: 'tags', label: 'Tags', icon: Icons.tag_rounded),
                _navItem(context, id: 'search', label: 'Search & AI', icon: Icons.search_rounded),
                _navItem(context, id: 'timeline', label: 'Timeline', icon: Icons.timeline_rounded),
              ],
            ),
          ),

          // Settings at bottom
          Padding(
            padding: const EdgeInsets.all(10),
            child: _navItem(context, id: 'settings', label: 'Settings', icon: Icons.settings_rounded),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String id,
    required String label,
    required IconData icon,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    final isSelected = activeView == id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onSelectView(id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
