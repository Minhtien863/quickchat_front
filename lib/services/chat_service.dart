class ConversationDTO {
  final String id;
  final String type; // 'direct' | 'group'
  final String? title;
  final String? avatarUrl;
  final int unreadCount;
  final MessageDTO? lastMessage;
  final DateTime createdAt;

  ConversationDTO({
    required this.id,
    required this.type,
    this.title,
    this.avatarUrl,
    required this.unreadCount,
    this.lastMessage,
    required this.createdAt,
  });
}

class AssetRefDTO {
  final String id, kind, url;
  final String? thumbUrl, mime;
  final int? size, durationMs;
  AssetRefDTO({
    required this.id, required this.kind, required this.url,
    this.thumbUrl, this.mime, this.size, this.durationMs,
  });
}

class ReactionDTO {
  final String emoji;
  final String userId;
  ReactionDTO({required this.emoji, required this.userId});
}

class MessageDTO {
  final String id;
  final String conversationId;
  final String senderId;
  final String type; // 'text'|'image'|'video'|'file'|'voice'|'system'
  final String? text;
  final AssetRefDTO? asset;
  final Map<String, dynamic>? replyTo;
  final List<ReactionDTO> reactions;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool deleted;

  MessageDTO({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.text,
    this.asset,
    this.replyTo,
    required this.reactions,
    required this.createdAt,
    this.editedAt,
    required this.deleted,
  });
}

class ScheduledMessageDTO {
  final String id;
  final String conversationId;
  final String text;
  final DateTime scheduleAt;
  final DateTime createdAt;
  final String status; // 'pending' | 'sent' | 'failed'

  ScheduledMessageDTO({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.scheduleAt,
    required this.createdAt,
    this.status = 'pending',
  });
}

abstract class ChatService {
  Future<List<ConversationDTO>> listConversations({String? q, int limit = 30, String? cursor});
  Future<List<MessageDTO>> listMessages(String conversationId, {int limit = 30, String? before});
  Future<MessageDTO> sendText(String conversationId, String text, {Map<String, dynamic>? replyTo});
  Future<void> addReaction(String messageId, String emoji);
  Future<void> removeReaction(String messageId, String emoji);

  Future<void> scheduleText(String conversationId, String text, DateTime when, {Map<String, dynamic>? replyTo});
  Future<List<ScheduledMessageDTO>> listScheduled({String? conversationId});
  Future<void> cancelScheduled(String scheduledId);
  Future<void> reschedule(String scheduledId, DateTime newWhen);
  Future<void> sendNow(String scheduledId); // mock "gửi ngay"
}

extension ChatServiceEmojiShim on ChatService {
  Future<MessageDTO> sendEmoji(
      String conversationId,
      String emoji, {
        Map<String, dynamic>? replyTo,
      }) {
    // Với mock hiện tại, coi emoji như 1 tin nhắn text
    return sendText(conversationId, emoji, replyTo: replyTo);
  }
}