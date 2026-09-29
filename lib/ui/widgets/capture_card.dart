import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/capture_item.dart';
import 'category_chip.dart';
import 'status_badge.dart';

class CaptureCard extends StatefulWidget {
  final CaptureItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(CaptureItem updated)? onUpdate;

  const CaptureCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.onUpdate,
  });

  @override
  State<CaptureCard> createState() => _CaptureCardState();
}

class _CaptureCardState extends State<CaptureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final file = File(item.imagePath);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? theme.colorScheme.primary : theme.dividerColor,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category + Status Badges + Action Menu
                Row(
                  children: [
                    CategoryChip(category: item.category),
                    const SizedBox(width: 8),
                    StatusBadge(status: item.status, isUncertain: item.isUncertain),
                    const Spacer(),
                    if (item.url != null && item.url!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        tooltip: 'Open Link (${item.url})',
                        onPressed: () => launchUrl(Uri.parse(item.url!)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      tooltip: 'Delete Item',
                      onPressed: widget.onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Main Body: Thumbnail & Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screenshot Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 90,
                        height: 70,
                        color: Colors.black26,
                        child: file.existsSync()
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_rounded, size: 24, color: Colors.grey),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.image_not_supported_rounded, size: 24, color: Colors.grey),
                              ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title & Content Preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.summary.isNotEmpty ? item.summary : item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Meta Info (Date, Time, Location, Price, Language, Due Date)
                if (_hasMeta(item)) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (item.date != null || item.time != null)
                        _metaItem(Icons.calendar_today_rounded, '${item.date ?? ''} ${item.time ?? ''}'.trim()),
                      if (item.dueDate != null)
                        _metaItem(Icons.event_available_rounded, 'Due: ${item.dueDate}'),
                      if (item.location != null && item.location!.isNotEmpty)
                        _metaItem(Icons.location_on_rounded, item.location!),
                      if (item.productName != null || item.price != null)
                        _metaItem(Icons.sell_rounded, '${item.currency ?? '\$'}${item.price ?? ''} (${item.store ?? 'Shopping'})'),
                      if (item.programmingLanguage != null && item.programmingLanguage!.isNotEmpty)
                        _metaItem(Icons.code_rounded, item.programmingLanguage!.toUpperCase()),
                    ],
                  ),
                ],

                // Footer Row: Tags + Created Time
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (item.tags.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: item.tags
                                .take(4)
                                .map((tag) => Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.dividerColor.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    Text(
                      DateFormat('MMM d, h:mm a').format(item.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasMeta(CaptureItem item) {
    return item.date != null ||
        item.dueDate != null ||
        (item.location != null && item.location!.isNotEmpty) ||
        item.price != null ||
        (item.programmingLanguage != null && item.programmingLanguage!.isNotEmpty);
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.cyan),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Colors.cyan),
        ),
      ],
    );
  }
}
