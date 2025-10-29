import 'dart:async';
import 'chat_service.dart';

class ChatServiceMock implements ChatService {
  final _me = 'u1';
  final List<ConversationDTO> _conversations = [];
  final Map<String, List<MessageDTO>> _messagesByConv = {};

  ChatServiceMock() {
    final c1 = ConversationDTO(
      id: 'c1',
      type: 'direct',
      title: '@hai.ng',
      avatarUrl: null,
      unreadCount: 1,
      lastMessage: MessageDTO(
        id: 'm2',
        conversationId: 'c1',
        senderId: 'u2',
        type: 'text',
        text: 'Chiều họp nhé',
        asset: null,
        replyTo: null,
        reactions: [ReactionDTO(emoji: '👍', userId: 'u1')],
        createdAt: DateTime.parse('2025-10-29T06:59:00Z'),
        editedAt: null,
        deleted: false,
      ),
      createdAt: DateTime.parse('2025-10-29T05:00:00Z'),
    );
    _conversations.add(c1);
    _messagesByConv['c1'] = [
      MessageDTO(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u2',
        type: 'text',
        text: 'Chào buổi sáng',
        asset: null,
        replyTo: null,
        reactions: [],
        createdAt: DateTime.parse('2025-10-29T06:30:00Z'),
        editedAt: null,
        deleted: false,
      ),
      c1.lastMessage!,
    ];
  }

  @override
  Future<List<ConversationDTO>> listConversations({String? q, int limit = 30, String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var list = _conversations;
    if ((q ?? '').trim().isNotEmpty) {
      list = list.where((c) => (c.title ?? '').toLowerCase().contains(q!.toLowerCase())).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }

  @override
  Future<List<MessageDTO>> listMessages(String conversationId, {int limit = 30, String? before}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final all = _messagesByConv[conversationId] ?? [];
    final sorted = [...all]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  @override
  Future<MessageDTO> sendText(String conversationId, String text, {Map<String, dynamic>? replyTo}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final msg = MessageDTO(
      id: 'm${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: _me,
      type: 'text',
      text: text,
      asset: null,
      replyTo: replyTo,
      reactions: [],
      createdAt: DateTime.now().toUtc(),
      editedAt: null,
      deleted: false,
    );
    _messagesByConv.putIfAbsent(conversationId, () => []).add(msg);
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx >= 0) {
      final old = _conversations[idx];
      _conversations[idx] = ConversationDTO(
        id: old.id,
        type: old.type,
        title: old.title,
        avatarUrl: old.avatarUrl,
        unreadCount: 0,
        lastMessage: msg,
        createdAt: DateTime.now().toUtc(),
      );
    }
    return msg;
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    final m = _findMsg(messageId);
    if (m == null) return;
    m.reactions.add(ReactionDTO(emoji: emoji, userId: _me));
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    final m = _findMsg(messageId);
    if (m == null) return;
    m.reactions.removeWhere((r) => r.emoji == emoji && r.userId == _me);
  }

  MessageDTO? _findMsg(String id) {
    for (final entry in _messagesByConv.entries) {
      for (final m in entry.value) {
        if (m.id == id) return m;
      }
    }
    return null;
  }
}
