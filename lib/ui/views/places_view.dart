import 'package:flutter/material.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';

class PlacesView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const PlacesView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final places = captures.where((e) => e.category == AppConstants.catPlace).toList();
    
    places.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: AppConstants.getCategoryColor(AppConstants.catPlace), size: 28),
                const SizedBox(width: 10),
                Text('Places & Locations', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${places.length} Places', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: places.isEmpty
                  ? const Center(child: Text('No places saved.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        final item = places[index];
                        return _buildPlaceCard(item, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(CaptureItem item, ThemeData theme) {
    final hasAddress = item.address != null && item.address!.isNotEmpty;
    final locationText = [item.city, item.country].where((e) => e != null && e.isNotEmpty).join(', ');

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
            // Left Pin Block
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(Icons.place_rounded, size: 40, color: theme.colorScheme.secondary),
              ),
            ),
            // Right Content
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
                    const SizedBox(height: 4),
                    if (hasAddress || locationText.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.map, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hasAddress ? item.address! : locationText,
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(
                      item.summary,
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
