import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes.dart';
import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';

import '../../services/service_registry.dart';
import '../../services/chat_service.dart';
import '../../widgets/chat_composer.dart';
import '../../widgets/reaction_bar.dart';
import '../../widgets/schedule_send_sheet.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String title;
  final String? avatarUrl;
  final String? avatarText;
  final String? subtitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.avatarUrl,
    this.avatarText,
    this.subtitle,
  });

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

  @override
  void dispose() {
    _inputC.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _future = Services.chat.listMessages(widget.conversationId);
    });
  }

  Future<void> _send() async {
    final t = _inputC.text.trim();
    if (t.isEmpty) return;
    _inputC.clear();
    await Services.chat.sendText(widget.conversationId, t);
    _reload();
  }

  String _fmtTime(DateTime t) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}  ${two(t.day)}/${two(t.month)}/${t.year}';
  }

  Future<void> _openMessageActions(BuildContext context, MessageDTO m) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final cs = Theme.of(context).colorScheme;
        final isMe = m.senderId == 'u1'; // TODO: bind user hiện tại

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- PREVIEW TIN NHẮN + THỜI GIAN ---
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text(m.senderId.characters.first.toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: isMe ? bubbleMe(context) : bubbleOther(),
                          child: _MessagePreviewContent(message: m),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                _fmtTime(m.createdAt),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),

            // --- KHAY EMOJI PHẢN HỒI ---
            ReactionBar(
              emojis: const ['❤️', '👍', '😂', '😮', '😢', '😡'],
              onPick: (emoji) async {
                Navigator.pop(context);
                try {
                  // nếu chưa có, bạn có thể thêm sau vào ChatService
                  // await Services.chat.sendEmoji(widget.conversationId, emoji);
                  await Services.chat.addReaction(m.id, emoji);
                } catch (_) {}
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Đã phản hồi $emoji')));
                }
              },
            ),
            const SizedBox(height: 8),

            // --- BẢNG TÙY CHỌN ---
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(blurRadius: 12, color: Colors.black26),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _ActionGrid(
                items: [
                  _ActionItem(
                    icon: Icons.reply_outlined,
                    label: 'Trả lời',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: set reply target
                    },
                  ),
                  _ActionItem(
                    icon: Icons.forward_to_inbox_outlined,
                    label: 'Chuyển tiếp',
                    onTap: () => Navigator.pop(context),
                  ),
                  _ActionItem(
                    icon: Icons.undo_rounded,
                    label: 'Thu hồi',
                    onTap: () => Navigator.pop(context),
                  ),
                  _ActionItem(
                    icon: Icons.push_pin_outlined,
                    label: 'Ghim',
                    onTap: () => Navigator.pop(context),
                  ),
                  _ActionItem(
                    icon: Icons.copy_all_outlined,
                    label: 'Sao chép',
                    onTap: () async {
                      Navigator.pop(context);
                      final txt = m.text ?? '';
                      if (txt.isNotEmpty) {
                        await Clipboard.setData(ClipboardData(text: txt));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép')),
                          );
                        }
                      }
                    },
                  ),
                  _ActionItem(
                    icon: Icons.info_outlined,
                    label: 'Chi tiết',
                    onTap: () {
                      Navigator.pop(context);
                      _showMessageDetail(context, m);
                    },
                  ),
                  _ActionItem(
                    icon: Icons.delete_outline,
                    label: 'Xóa',
                    danger: true,
                    onTap: () async {
                      final ok = await _confirm(context, 'Xóa tin nhắn này?');
                      if (ok == true) Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirm(BuildContext context, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showMessageDetail(BuildContext context, MessageDTO m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chi tiết tin nhắn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${m.id}'),
            Text('Người gửi: ${m.senderId}'),
            Text('Loại: ${m.type}'),
            Text('Thời gian: ${m.createdAt}'),
            if (m.text != null) Text('Nội dung: ${m.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.chat(
        title: widget.title,
        subtitle: widget.subtitle ?? 'Truy cập 4 giờ trước',
        avatarUrl: widget.avatarUrl,
        avatarFallback: widget.avatarText,
        onBack: () => Navigator.pop(context),
        onCall: () {
          Navigator.pushNamed(
            context,
            AppRoutes.voiceCall,
            arguments: {
              'peerId': 'u2', // TODO: bind thật
              'peerName': widget.title,
              'avatarUrl': widget.avatarUrl,
            },
          );
        },
        onVideo: () {
          Navigator.pushNamed(
            context,
            AppRoutes.videoCall,
            arguments: {
              'peerId': 'u2',
              'peerName': widget.title,
              'avatarUrl': widget.avatarUrl,
            },
          );
        },
        onMore: () {
          Navigator.pushNamed(
            context,
            AppRoutes.chatSettings,
            arguments: {
              'conversationId': widget.conversationId,
              'title': widget.title,
              'avatarUrl': widget.avatarUrl,
              'avatarText': widget.avatarText,
            },
          );
        },
      ),
      resizeToAvoidBottomInset: true,
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
                if (msgs.isEmpty) {
                  return const Center(child: Text('Bắt đầu cuộc trò chuyện'));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 92),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[msgs.length - 1 - i];
                    final isMe = m.senderId == 'u1'; // TODO
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: InkWell(
                        onLongPress: () => _openMessageActions(context, m),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: isMe ? bubbleMe(context) : bubbleOther(),
                          child: Text(m.text ?? '[${m.type}]'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChatComposer(
              onSendText: (t) async {
                await Services.chat.sendText(widget.conversationId, t);
                _reload();
              },
              onPickCamera: () {},
              onPickGallery: () {},
              onToggleEmoji: () {},
              onSendLike: () async {
                try {
                  await Services.chat.sendEmoji(
                    widget.conversationId,
                    '👍',
                  ); // nếu có
                } catch (_) {}
                _reload();
              },
              isSending: false,
              onLongPressSend: (text) async {
                final t = text.trim();
                if (t.isEmpty) return false;

                final choice = await showScheduleSendSheet(
                  context,
                  draftText: t,
                  peerName: widget.title,
                );

                if (choice == null) return false; // user hủy

                if (choice.whenOnline) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã đặt: gửi khi ${widget.title} trực tuyến',
                      ),
                    ),
                  );
                  return true; // báo composer clear
                }

                if (choice.scheduledAt != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã hẹn lúc ${choice.scheduledAt}')),
                  );
                  return true; // báo composer clear
                }

                return false;
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ====== PREVIEW CONTENT (text / image / video / file stub) ====== */
class _MessagePreviewContent extends StatelessWidget {
  final MessageDTO message;

  const _MessagePreviewContent({required this.message});

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case 'image':
        final url = message.asset?.thumbUrl ?? message.asset?.url;
        if (url != null && url.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 180,
              height: 120,
              fit: BoxFit.cover,
            ),
          );
        }
        return _stub(Icons.image, 'Ảnh');
      case 'video':
        return _stub(Icons.play_circle_outline, 'Video');
      case 'file':
        return _stub(
          Icons.insert_drive_file_outlined,
          message.asset?.mime ?? 'Tệp',
        );
      default:
        return Text(
          message.text ?? '[${message.type}]',
          style: const TextStyle(fontSize: 15),
        );
    }
  }

  Widget _stub(IconData ic, String label) {
    return Container(
      width: 180,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

/* ====== ACTION GRID ====== */
class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });
}

class _ActionGrid extends StatelessWidget {
  final List<_ActionItem> items;

  const _ActionGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 92,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        final it = items[i];
        final color = it.danger ? Colors.red : cs.primary;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: it.onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: it.danger
                      ? Colors.red.withOpacity(.10)
                      : cs.primaryContainer.withOpacity(.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(it.icon, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                it.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: it.danger ? Colors.red : cs.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _pad2(int x) => x.toString().padLeft(2, '0');

String _fmtFull(DateTime t) =>
    '${_pad2(t.day)}/${_pad2(t.month)}/${t.year} • ${_pad2(t.hour)}:${_pad2(t.minute)}';

Future<DateTime?> _pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final firstDate = now;
  final initDate = initial ?? now.add(const Duration(minutes: 5));
  final d = await showDatePicker(
    context: context,
    initialDate: initDate,
    firstDate: firstDate,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (d == null) return null;
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: initDate.hour, minute: initDate.minute),
  );
  if (t == null) return null;
  return DateTime(d.year, d.month, d.day, t.hour, t.minute);
}
