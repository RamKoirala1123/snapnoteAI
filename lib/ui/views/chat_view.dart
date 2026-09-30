import 'package:flutter/material.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/capture_item.dart';
import '../../core/services/ai_service.dart';
import '../widgets/capture_card.dart';
import '../widgets/k_components.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final List<CaptureItem>? relatedItems;
  final bool isThinking;

  ChatMessage({
    required this.isUser,
    required this.text,
    this.relatedItems,
    this.isThinking = false,
  });
}

class ChatView extends StatefulWidget {
  final List<CaptureItem> captures;
  final AppSettings settings;
  final Function(CaptureItem) onItemTap;

  const ChatView({
    super.key,
    required this.captures,
    required this.settings,
    required this.onItemTap,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CustomAIApiService _aiService = CustomAIApiService();

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        isUser: false,
        text: 'Hello! I am your AI Copilot. You can ask me anything about your notes, tasks, events, and captured screenshots.',
      ),
    );
  }

  Future<void> _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: query));
      _messages.add(ChatMessage(isUser: false, text: 'Thinking...', isThinking: true));
    });

    _scrollToBottom();

    try {
      final res = await _aiService.naturalLanguageSearch(
        query: query,
        items: widget.captures,
        apiKey: widget.settings.geminiApiKey,
        modelName: widget.settings.aiModel,
      );

      final answer = res['answer'] as String? ?? 'No answer provided.';
      final itemIdsDynamic = res['item_ids'] as List?;
      final List<String> itemIds = itemIdsDynamic?.map((e) => e.toString()).toList() ?? [];

      final relatedItems = widget.captures.where((e) => itemIds.contains(e.id)).toList();

      setState(() {
        _messages.removeLast(); // Remove "Thinking..."
        _messages.add(ChatMessage(isUser: false, text: answer, relatedItems: relatedItems));
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(isUser: false, text: 'Error connecting to AI: $e'));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KScaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 10),
                Text('AI Copilot', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index], theme);
              },
            ),
          ),
          
          // Input Field
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask about your notes (e.g. "What did I save about Flutter?")',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: KButton.icon(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, ThemeData theme) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: Column(
          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: msg.isUser ? theme.colorScheme.primary : theme.cardColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(16),
                  bottomLeft: msg.isUser ? const Radius.circular(16) : const Radius.circular(0),
                ),
                border: msg.isUser ? null : Border.all(color: theme.dividerColor),
              ),
              child: msg.isThinking
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(msg.text, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      ],
                    )
                  : Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
            ),
            if (msg.relatedItems != null && msg.relatedItems!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: msg.relatedItems!.map((item) => ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: CaptureCard(
                    item: item,
                    onTap: () => widget.onItemTap(item),
                    onDelete: () {}, // hide delete in chat view for simplicity
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
