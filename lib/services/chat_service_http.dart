import 'dart:convert';
import 'package:http/http.dart' as http;

import 'chat_service.dart';
import 'auth_service_http.dart';

class ChatServiceHttp implements ChatService {
  final String baseUrl;
  final AuthServiceHttp auth;

  ChatServiceHttp({
    required this.baseUrl,
    required this.auth,
  });

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    if (auth.accessToken != null)
      'Authorization': 'Bearer ${auth.accessToken}',
  };

  Exception _errorFromResponse(http.Response res) {
    try {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = data['message']?.toString() ?? 'Lỗi ${res.statusCode}';
      return Exception(msg);
    } catch (_) {
      return Exception('Lỗi ${res.statusCode}');
    }
  }

  ConversationDTO _parseConversation(Map<String, dynamic> c) {
    return ConversationDTO(
      id: c['id'] as String,
      type: c['type'] as String,
      title: c['title'] as String?,
      avatarUrl: c['avatarUrl'] as String?,
      unreadCount: c['unreadCount'] as int? ?? 0,
      lastMessage: c['lastMessage'] == null
          ? null
          : _parseMessage(c['lastMessage'] as Map<String, dynamic>),
      createdAt: DateTime.parse(c['createdAt'] as String),
    );
  }

  MessageDTO _parseMessage(Map<String, dynamic> m) {
    AssetRefDTO? asset;
    final a = m['asset'];
    if (a is Map<String, dynamic>) {
      asset = AssetRefDTO(
        id: a['id'] as String,
        kind: a['kind'] as String,
        url: a['url'] as String,
        thumbUrl: a['thumbUrl'] as String?,
        mime: a['mime'] as String?,
        size: a['size'] as int?,
        durationMs: a['durationMs'] as int?,
      );
    }

    final reactions = <ReactionDTO>[];
    final rList = m['reactions'];
    if (rList is List) {
      for (final r in rList) {
        if (r is Map<String, dynamic>) {
          reactions.add(ReactionDTO(
            emoji: r['emoji'] as String,
            userId: r['userId'] as String,
          ));
        }
      }
    }

    return MessageDTO(
      id: m['id'] as String,
      conversationId: m['conversationId'] as String,
      senderId: m['senderId'] as String,
      type: m['type'] as String,
      text: m['text'] as String?,
      asset: asset,
      replyTo: m['replyTo'] as Map<String, dynamic>?,
      reactions: reactions,
      createdAt: DateTime.parse(m['createdAt'] as String),
      editedAt: m['editedAt'] != null
          ? DateTime.parse(m['editedAt'] as String)
          : null,
      deleted: m['deleted'] as bool? ?? false,
    );
  }

  @override
  Future<List<ConversationDTO>> listConversations({
    String? q,
    int limit = 30,
    String? cursor,
  }) async {
    final uri = Uri.parse('$baseUrl/api/chat/conversations')
        .replace(queryParameters: {
      'limit': '$limit',
      if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      if (cursor != null) 'cursor': cursor,
    });

    final res = await http.get(uri, headers: _jsonHeaders);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['conversations'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(_parseConversation)
          .toList();
    }
    throw _errorFromResponse(res);
  }

  @override
  Future<List<MessageDTO>> listMessages(
      String conversationId, {
        int limit = 30,
        String? before,
      }) async {
    final uri = Uri.parse(
      '$baseUrl/api/chat/conversations/$conversationId/messages',
    ).replace(queryParameters: {
      'limit': '$limit',
      if (before != null) 'before': before,
    });

    final res = await http.get(uri, headers: _jsonHeaders);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['messages'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(_parseMessage)
          .toList();
    }
    throw _errorFromResponse(res);
  }

  @override
  Future<MessageDTO> sendText(
      String conversationId,
      String text, {
        Map<String, dynamic>? replyTo,
      }) async {
    final uri =
    Uri.parse('$baseUrl/api/chat/conversations/$conversationId/messages');

    final body = jsonEncode({
      'text': text,
      if (replyTo != null) 'replyTo': replyTo,
    });

    final res = await http.post(uri, headers: _jsonHeaders, body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final m = data['message'] as Map<String, dynamic>;
      return _parseMessage(m);
    }
    throw _errorFromResponse(res);
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    final uri =
    Uri.parse('$baseUrl/api/chat/messages/$messageId/reactions');
    final res = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'emoji': emoji}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw _errorFromResponse(res);
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    final uri =
    Uri.parse('$baseUrl/api/chat/messages/$messageId/reactions');
    final res = await http.delete(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode({'emoji': emoji}),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw _errorFromResponse(res);
  }

  // các hàm schedule hiện chưa có backend -> tạm mock rỗng

  @override
  Future<void> scheduleText(
      String conversationId,
      String text,
      DateTime when, {
        Map<String, dynamic>? replyTo,
      }) async {
    // TODO: implement backend sau
    return;
  }

  @override
  Future<List<ScheduledMessageDTO>> listScheduled({
    String? conversationId,
  }) async {
    return [];
  }

  @override
  Future<void> cancelScheduled(String scheduledId) async {
    return;
  }

  @override
  Future<void> reschedule(
      String scheduledId,
      DateTime newWhen,
      ) async {
    return;
  }

  @override
  Future<void> sendNow(String scheduledId) async {
    return;
  }
}
