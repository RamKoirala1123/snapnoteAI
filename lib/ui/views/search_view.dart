import 'package:flutter/material.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/capture_item.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/constants.dart';
import '../widgets/capture_card.dart';
import '../widgets/k_components.dart';

class SearchView extends StatefulWidget {
  final List<CaptureItem> captures;
  final AppSettings settings;
  final Function(CaptureItem item) onItemTap;
  final Function(String id) onItemDelete;

  const SearchView({
    super.key,
    required this.captures,
    required this.settings,
    required this.onItemTap,
    required this.onItemDelete,
  });

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Text search state
  final TextEditingController _queryController = TextEditingController();
  String _selectedCategory = 'all';

  // Natural language state
  final TextEditingController _nlController = TextEditingController();
  bool _isNlSearching = false;
  String? _nlAnswer;
  List<String> _nlMatchingIds = [];

  final CustomAIApiService _aiService = CustomAIApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _queryController.dispose();
    _nlController.dispose();
    super.dispose();
  }

  Future<void> _performNlSearch() async {
    final query = _nlController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isNlSearching = true;
      _nlAnswer = null;
      _nlMatchingIds = [];
    });

    try {
      final res = await _aiService.naturalLanguageSearch(
        query: query,
        items: widget.captures,
        apiKey: widget.settings.geminiApiKey,
        modelName: widget.settings.aiModel,
      );

      setState(() {
        _nlAnswer = res['answer'] as String?;
        _nlMatchingIds = (res['item_ids'] as List?)?.map((e) => e.toString()).toList() ?? [];
      });
    } catch (e) {
      setState(() {
        _nlAnswer = 'Error executing natural language query: $e';
      });
    } finally {
      setState(() => _isNlSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KScaffold(
      backgroundColor: Colors.transparent,
      title: 'Search Knowledge Base',
      subtitle: 'Find your saved captures',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.saved_search_rounded, size: 18), text: 'Structured & Keyword Search'),
                Tab(icon: Icon(Icons.psychology_rounded, size: 18), text: '🤖 Natural Language AI Search'),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStructuredSearchTab(theme),
                  _buildNlSearchTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredSearchTab(ThemeData theme) {
    final q = _queryController.text.toLowerCase().trim();

    final filtered = widget.captures.where((item) {
      if (_selectedCategory != 'all' && item.category != _selectedCategory) {
        return false;
      }
      if (q.isNotEmpty) {
        final inTitle = item.title.toLowerCase().contains(q);
        final inSummary = item.summary.toLowerCase().contains(q);
        final inContent = item.content.toLowerCase().contains(q);
        final inTags = item.tags.any((t) => t.toLowerCase().contains(q));
        final inUrl = item.url?.toLowerCase().contains(q) ?? false;
        final inLoc = item.location?.toLowerCase().contains(q) ?? false;
        return inTitle || inSummary || inContent || inTags || inUrl || inLoc;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _queryController,
                decoration: const InputDecoration(
                  hintText: 'Search titles, summaries, tags, URLs, code, locations...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownMenu<String>(
                initialSelection: _selectedCategory,
                label: const Text('Category'),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: 'all', label: 'All Categories'),
                  ...AppConstants.allCategories.map((c) => DropdownMenuEntry(
                        value: c,
                        label: AppConstants.getCategoryLabel(c),
                      )),
                ],
                onSelected: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No matching captures found.', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return CaptureCard(
                      item: item,
                      onTap: () => widget.onItemTap(item),
                      onDelete: () => widget.onItemDelete(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNlSearchTab(ThemeData theme) {
    final matchingItems = widget.captures.where((e) => _nlMatchingIds.contains(e.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nlController,
                decoration: const InputDecoration(
                  hintText: 'Ask anything e.g. "Show me things I saved about Flutter" or "Find articles on performance"',
                  prefixIcon: Icon(Icons.psychology_rounded, color: Colors.purpleAccent),
                ),
                onSubmitted: (_) => _performNlSearch(),
              ),
            ),
            const SizedBox(width: 12),
            KButton.primaryIcon(
              onPressed: _isNlSearching ? null : _performNlSearch,
              icon: _isNlSearching
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome_rounded),
              label: const Text('Ask AI'),
              ),
          ],
        ),

        const SizedBox(height: 16),

        if (_nlAnswer != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Text('AI Answer Summary', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_nlAnswer!, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Expanded(
          child: matchingItems.isEmpty
              ? Center(
                  child: Text(
                    _nlAnswer == null ? 'Ask AI to find information saved across all your captures.' : 'No matching capture cards.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: matchingItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = matchingItems[index];
                    return CaptureCard(
                      item: item,
                      onTap: () => widget.onItemTap(item),
                      onDelete: () => widget.onItemDelete(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
