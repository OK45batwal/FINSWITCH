import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[
    _ChatMessage('Hello! I\'m FinSwitch AI. How can I help you with your investments today?', true),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _messages.add(_ChatMessage(text, false)));
    setState(() => _busy = true);
    try {
      final r = await Api.post('/ai/chat', {'message': text, 'history': _messages.map((m) => {'role': m.isBot ? 'assistant' : 'user', 'content': m.text}).toList()});
      final reply = r['reply'] ?? r['data']?['reply'] ?? 'Sorry, I couldn\'t process that.';
      if (mounted) setState(() => _messages.add(_ChatMessage(reply, true)));
    } catch (e) {
      if (mounted) setState(() => _messages.add(_ChatMessage('Error: Could not reach FinSwitch AI. Is the server running?', true)));
    }
    if (mounted) setState(() => _busy = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 20),
        const SizedBox(width: 6),
        const Text('FinSwitch AI'),
      ])),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _ChatBubble(message: _messages[i]),
            ),
          ),
          if (_busy) const Padding(padding: EdgeInsets.only(bottom: 8), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.card, border: Border(top: const BorderSide(color: Colors.white10))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Ask about stocks, markets, or strategies...'),
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(14)),
                child: IconButton(icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20), onPressed: _send, padding: EdgeInsets.zero)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  _ChatMessage(this.text, this.isBot);
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: message.isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.isBot) ...[
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 16)),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: message.isBot ? const Color(0xFF1A2538) : AppTheme.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(message.isBot ? 4 : 16), bottomRight: Radius.circular(message.isBot ? 16 : 4),
              ),
            ),
            child: Text(message.text, style: TextStyle(fontSize: 14, height: 1.5, color: message.isBot ? AppTheme.text : Colors.white)),
          ),
        ),
      ],
    );
  }
}
