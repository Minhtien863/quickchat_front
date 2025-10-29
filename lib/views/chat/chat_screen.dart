import 'package:flutter/material.dart';
import '../../services/service_registry.dart';
import '../../services/chat_service.dart';
import '../../widgets/tokens.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String title;
  const ChatScreen({super.key, required this.conversationId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputC = TextEditingController();
  late Future<List<MessageDTO>> _future;

  @override
  void initState() {
    super.initState();
    _future = Services.chat.listMessages(widget.conversationId);
  }

  Future<void> _reload() async {
    setState(() => _future = Services.chat.listMessages(widget.conversationId));
  }

  Future<void> _send() async {
    final t = _inputC.text.trim();
    if (t.isEmpty) return;
    _inputC.clear();
    await Services.chat.sendText(widget.conversationId, t);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<MessageDTO>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snap.data ?? [];
                if (msgs.isEmpty) return const Center(child: Text('Bắt đầu cuộc trò chuyện'));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final isMe = m.senderId == 'u1'; // mock
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: isMe ? bubbleMe(context) : bubbleOther(),
                        child: Text(m.text ?? '[${m.type}]'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputC,
                      decoration: const InputDecoration(hintText: 'Nhập tin nhắn...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Gửi'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
