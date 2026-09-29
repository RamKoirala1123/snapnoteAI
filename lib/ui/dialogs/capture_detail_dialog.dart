import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/category_chip.dart';
import '../widgets/status_badge.dart';

class CaptureDetailDialog extends StatefulWidget {
  final CaptureItem item;
  final Function(CaptureItem updatedItem) onSave;
  final VoidCallback onDelete;
  final VoidCallback? onRetryAI;

  const CaptureDetailDialog({
    super.key,
    required this.item,
    required this.onSave,
    required this.onDelete,
    this.onRetryAI,
  });

  static Future<void> show(
    BuildContext context, {
    required CaptureItem item,
    required Function(CaptureItem updatedItem) onSave,
    required VoidCallback onDelete,
    VoidCallback? onRetryAI,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => CaptureDetailDialog(
        item: item,
        onSave: onSave,
        onDelete: onDelete,
        onRetryAI: onRetryAI,
      ),
    );
  }

  @override
  State<CaptureDetailDialog> createState() => _CaptureDetailDialogState();
}

class _CaptureDetailDialogState extends State<CaptureDetailDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late String _category;
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _urlController;
  late TextEditingController _priceController;
  late TextEditingController _storeController;
  late TextEditingController _languageController;

  bool _isCompleted = false;
  bool _isRead = false;
  bool _isPurchased = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    final item = widget.item;
    _category = item.category;
    _titleController = TextEditingController(text: item.title);
    _summaryController = TextEditingController(text: item.summary);
    _contentController = TextEditingController(text: item.content);
    _tagsController = TextEditingController(text: item.tags.join(', '));
    _dateController = TextEditingController(text: item.date ?? item.dueDate ?? '');
    _timeController = TextEditingController(text: item.time ?? '');
    _locationController = TextEditingController(text: item.location ?? '');
    _urlController = TextEditingController(text: item.url ?? '');
    _priceController = TextEditingController(text: item.price ?? '');
    _storeController = TextEditingController(text: item.store ?? '');
    _languageController = TextEditingController(text: item.programmingLanguage ?? '');

    _isCompleted = item.isCompleted;
    _isRead = item.isRead;
    _isPurchased = item.isPurchased;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    _priceController.dispose();
    _storeController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final parsedTags = _tagsController.text
        .split(',')
        .map((e) => e.trim().replaceAll('#', ''))
        .where((e) => e.isNotEmpty)
        .toList();

    final updated = widget.item.copyWith(
      category: _category,
      title: _titleController.text.trim(),
      summary: _summaryController.text.trim(),
      content: _contentController.text.trim(),
      tags: parsedTags,
      date: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      url: _urlController.text.trim().isEmpty ? null : _urlController.text.trim(),
      price: _priceController.text.trim().isEmpty ? null : _priceController.text.trim(),
      store: _storeController.text.trim().isEmpty ? null : _storeController.text.trim(),
      programmingLanguage: _languageController.text.trim().isEmpty ? null : _languageController.text.trim(),
      isCompleted: _isCompleted,
      isRead: _isRead,
      isPurchased: _isPurchased,
      isUncertain: false, // User verified
      status: 'completed',
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(widget.item.imagePath);

    return Dialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 820,
        height: 680,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top Bar
            Row(
              children: [
                CategoryChip(category: _category),
                const SizedBox(width: 8),
                StatusBadge(status: widget.item.status, isUncertain: widget.item.isUncertain),
                const SizedBox(width: 12),
                if (widget.item.category != widget.item.originalCategory)
                  Tooltip(
                    message: 'Original AI classification was ${widget.item.originalCategory}',
                    child: Text(
                      '(AI classified as ${widget.item.originalCategory})',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                const Spacer(),
                if (widget.onRetryAI != null)
                  OutlinedButton.icon(
                    onPressed: widget.onRetryAI,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Retry AI', style: TextStyle(fontSize: 12)),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tab Bar Navigation
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.edit_note_rounded, size: 18), text: 'Details & Edit'),
                Tab(icon: Icon(Icons.article_rounded, size: 18), text: 'Markdown Reader'),
                Tab(icon: Icon(Icons.image_rounded, size: 18), text: 'Original Screenshot'),
                Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'AI Debug Payload'),
              ],
            ),

            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Details & Edit
                  _buildEditTab(theme),

                  // Tab 2: Markdown Preview
                  _buildMarkdownTab(theme),

                  // Tab 3: Original Screenshot
                  _buildScreenshotTab(file, theme),

                  // Tab 4: AI Raw Debug Payload
                  _buildDebugTab(theme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Footer Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    widget.onDelete();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                  label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownMenu<String>(
                  initialSelection: _category,
                  label: const Text('Category'),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: AppConstants.allCategories
                      .map((c) => DropdownMenuEntry(
                            value: c,
                            label: AppConstants.getCategoryLabel(c),
                          ))
                      .toList(),
                  onSelected: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _summaryController,
            decoration: const InputDecoration(labelText: 'Summary'),
            maxLines: 2,
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Main Content (Markdown supported)'),
            maxLines: 6,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Date / Due Date (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today, size: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Time (HH:mm)', prefixIcon: Icon(Icons.access_time, size: 16)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location / Venue', prefixIcon: Icon(Icons.location_on_outlined, size: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL / Source Link', prefixIcon: Icon(Icons.link, size: 16)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money, size: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _storeController,
                  decoration: const InputDecoration(labelText: 'Store Name', prefixIcon: Icon(Icons.store, size: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _languageController,
                  decoration: const InputDecoration(labelText: 'Code Language', prefixIcon: Icon(Icons.code, size: 16)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(labelText: 'Tags (comma separated)', prefixIcon: Icon(Icons.tag, size: 16)),
          ),

          const SizedBox(height: 12),

          // Checkbox Toggles
          Row(
            children: [
              FilterChip(
                label: Text(_isCompleted ? '✓ Completed' : 'Task Completed'),
                selected: _isCompleted,
                onSelected: (val) => setState(() => _isCompleted = val),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: Text(_isRead ? '📚 Read' : 'Unread Article'),
                selected: _isRead,
                onSelected: (val) => setState(() => _isRead = val),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: Text(_isPurchased ? '🛒 Purchased' : 'Shopping Item'),
                selected: _isPurchased,
                onSelected: (val) => setState(() => _isPurchased = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownTab(ThemeData theme) {
    final md = _contentController.text.isNotEmpty
        ? _contentController.text
        : widget.item.content;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Markdown(
        data: md.isEmpty ? '_No content available._' : md,
        selectable: true,
        onTapLink: (text, href, title) {
          if (href != null) launchUrl(Uri.parse(href));
        },
      ),
    );
  }

  Widget _buildScreenshotTab(File file, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: file.existsSync()
          ? InteractiveViewer(
              child: Image.file(
                file,
                fit: BoxFit.contain,
              ),
            )
          : const Center(
              child: Text('Original screenshot file missing.', style: TextStyle(color: Colors.white)),
            ),
    );
  }

  Widget _buildDebugTab(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          widget.item.aiJsonPayload ?? 'No raw AI JSON payload captured.',
          style: const TextStyle(
            fontFamily: 'Consolas',
            fontSize: 12,
            color: Color(0xFF7EE787),
          ),
        ),
      ),
    );
  }
}
