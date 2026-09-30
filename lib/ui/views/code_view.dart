import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/github.dart';
import '../../core/models/capture_item.dart';
import '../../core/utils/constants.dart';
import '../widgets/k_components.dart';

class CodeView extends StatelessWidget {
  final List<CaptureItem> captures;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const CodeView({
    super.key,
    required this.captures,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snippets = captures.where((e) => e.category == AppConstants.catCode).toList();
    
    snippets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_rounded, color: AppConstants.getCategoryColor(AppConstants.catCode), size: 28),
                const SizedBox(width: 10),
                Text('Code Snippets Repository', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${snippets.length} Snippets', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: snippets.isEmpty
                  ? const Center(child: Text('No code snippets captured.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: snippets.length,
                      itemBuilder: (context, index) {
                        final item = snippets[index];
                        final language = item.programmingLanguage ?? 'code';
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    if (language.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          language.toUpperCase(),
                                          style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    KButton.icon(
                                      icon: const Icon(Icons.copy_rounded, size: 18),
                                      tooltip: 'Copy Raw Content',
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: item.content));
                                      },
                                    ),
                                    KButton.icon(
                                      icon: const Icon(Icons.open_in_full_rounded, size: 18),
                                      tooltip: 'View Details',
                                      onPressed: () => onItemTap(item),
                                    ),
                                    KButton.icon(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                      tooltip: 'Delete Snippet',
                                      onPressed: () => onItemDelete(item.id),
                                    ),
                                  ],
                                ),
                              ),
                              // Markdown Body
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: MarkdownBody(
                                  data: item.content.isEmpty ? '```\nNo code content.\n```' : item.content,
                                  selectable: true,
                                  builders: {
                                    'code': _CodeElementBuilder(theme),
                                  },
                                ),
                              ),
                            ],
                          ),
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

class _CodeElementBuilder extends MarkdownElementBuilder {
  final ThemeData theme;
  _CodeElementBuilder(this.theme);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      if (lg.startsWith('language-')) {
        language = lg.substring(9);
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: HighlightView(
        element.textContent,
        language: language.isEmpty ? 'dart' : language, // default to dart if none specified
        theme: theme.brightness == Brightness.dark ? atomOneDarkTheme : githubTheme,
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}
