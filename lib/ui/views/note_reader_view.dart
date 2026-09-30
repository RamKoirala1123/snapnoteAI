import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/models/capture_item.dart';
import '../widgets/k_components.dart';

class NoteReaderView extends StatelessWidget {
  final CaptureItem note;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const NoteReaderView({
    super.key,
    required this.note,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                KButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack,
                  tooltip: 'Go Back',
                ),
                const SizedBox(width: 16),
                Text('Reading Mode', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                const Spacer(),
                if (note.imagePath.isNotEmpty) ...[
                  KButton.textIcon(
                    icon: const Icon(Icons.image_rounded, size: 16),
                    label: const Text('View Original'),
                    onPressed: () => _showOriginalCaptureDialog(context),
                  ),
                  const SizedBox(width: 8),
                ],
                KButton.primaryIcon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('Edit Note'),
                  onPressed: onEdit,
                  ),
              ],
            ),
          ),

          // Main Reading Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                            Text(
                              note.title,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Captured on ${note.createdAt.toString().split(' ')[0]}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (note.tags.isNotEmpty) ...[
                                  const SizedBox(width: 8), // Replaces the 16 width from before between segments
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.local_offer_rounded, size: 14, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          note.tags.join(', '),
                                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            MarkdownBody(
                              data: note.content.isNotEmpty ? note.content : note.summary,
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                h1: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
                                h2: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
                                h3: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.5),
                                p: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16),
                                listBullet: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                                code: TextStyle(
                                  backgroundColor: theme.brightness == Brightness.dark 
                                      ? Colors.grey.shade900 
                                      : Colors.grey.shade200,
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                                codeblockDecoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark 
                                      ? Colors.black26 
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 64),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showOriginalCaptureDialog(BuildContext context) {
    if (note.imagePath.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.file(
                File(note.imagePath),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: KButton.icon(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
