import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/capture_item.dart';
import '../../core/app_typography.dart';
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
            color: _isHovered ? theme.dividerColor : Colors.transparent,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Side: Content (Title, Description, Tags, Type)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        item.summary.isNotEmpty ? item.summary : item.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyLarge.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      
                      // Meta Info (Date, Time, Location, Price, Language, Due Date)
                      if (_hasMeta(item)) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
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

                      const SizedBox(height: 12),
                      
                      // Tags and Type
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CategoryChip(category: item.category),
                          if (item.isUncertain || item.status == 'needs_review')
                            StatusBadge(status: item.status, isUncertain: item.isUncertain),
                          ...item.tags.take(4).map((tag) => Text(
                            '#$tag',
                            style: context.bodySmall.muted(context).copyWith(fontWeight: FontWeight.w500),
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Right Side: Date, Actions, Thumbnail
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Date & Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMM d').format(item.createdAt),
                          style: context.bodySmall.muted(context),
                        ),
                        if (item.url != null && item.url!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => launchUrl(Uri.parse(item.url!)),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(Icons.open_in_new_rounded, size: 16, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: widget.onDelete,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(Icons.delete_outline_rounded, size: 16, color: theme.iconTheme.color?.withValues(alpha: 0.5)),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Small Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        child: file.existsSync()
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.broken_image_rounded, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.3)),
                              )
                            : Icon(Icons.image_not_supported_rounded, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.3)),
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
        Icon(icon, size: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Text(
          text,
          style: context.labelMedium.muted(context),
        ),
      ],
    );
  }
}
