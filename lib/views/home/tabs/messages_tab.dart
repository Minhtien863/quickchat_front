import 'package:flutter/material.dart';
import '../../../routes.dart';
import '../../../services/service_registry.dart';
import '../../../services/chat_service.dart';
import '../../../widgets/q_search_field.dart';
import '../../../widgets/q_tiles.dart';
import '../../../widgets/tokens.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});
  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  String _q = '';
  late Future<List<ConversationDTO>> _future;

  @override
  void initState() {
    super.initState();
    _future = Services.chat.listConversations();
  }

  void _search(String v) {
    setState(() {
      _q = v;
      _future = Services.chat.listConversations(q: v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Column(
          children: [
            QSearchField(hint: 'Tìm cuộc trò chuyện', onChanged: _search),
            Gaps.md,
            Expanded(
              child: FutureBuilder<List<ConversationDTO>>(
                future: _future,
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snap.data ?? [];
                  if (data.isEmpty) {
                    return Center(child: Text(_q.isEmpty ? 'Chưa có cuộc trò chuyện' : 'Không tìm thấy “$_q”'));
                  }
                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final c = data[i];
                      return ConversationTile(
                        c: c,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.chat,
                          arguments: {'conversationId': c.id, 'title': c.title ?? 'Chat'},
                        ),
                      );
                    },
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
