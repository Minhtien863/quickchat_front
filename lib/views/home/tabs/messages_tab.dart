import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../services/service_registry.dart';
import '../../../services/chat_service.dart';
import '../../../widgets/q_tiles.dart';
import '../../../widgets/tokens.dart';

import '../../../services/hidden_chat_prefs.dart';
import '../../../widgets/pin_sheet.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});
  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  late Future<List<ConversationDTO>> _future;

  // Mock trạng thái bật/tắt thông báo theo conversationId
  final Set<String> _mutedIds = <String>{};
  final Set<String> _unreadIds = <String>{};

  @override
  void initState() {
    super.initState();
    _future = Services.chat.listConversations();
  }

  Future<void> _reload() async {
    setState(() => _future = Services.chat.listConversations());
    await _future; // để RefreshIndicator chờ đúng
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConversationDTO>>(
      future: _future,
      builder: (_, snap) {
        final data = snap.data ?? [];
        return ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = data[i];
            final title  = c.title ?? 'Chat';
            final muted  = _mutedIds.contains(c.id);
            final unread = _unreadIds.contains(c.id);
            final type   = c.type; // 'direct' | 'group'

            return GestureDetector(
              onLongPress: () => openConversationOptions(
                context,
                conversationId: c.id,
                title: title,
                type: type,
                muted: muted,
                unread: unread,
                canAddMembers: type == 'group' /* && TODO: quyền thật */,
                onToggleMute: (v) {
                  setState(() {
                    if (v) _mutedIds.add(c.id); else _mutedIds.remove(c.id);
                  });
                },
                onToggleUnread: (v) {
                  setState(() {
                    if (v) _unreadIds.add(c.id); else _unreadIds.remove(c.id);
                  });
                },
                onEnterMultiSelect: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chế độ chọn nhiều (mock)')),
                  );
                },
                onDelete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã xoá "$title" (mock)')),
                  );
                },

                // Cá nhân:
                onCreateGroupWithUser: () {
                  Navigator.pushNamed(context, AppRoutes.createGroup);
                },
                onBlockUser: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã chặn (mock)')),
                  );
                },

                // Nhóm:
                onLeaveGroup: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Rời nhóm?'),
                      content: Text('Bạn sẽ rời "$title".'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Rời')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã rời nhóm (mock)')),
                    );
                  }
                },
                onAddMembers: () {
                  // TODO: điều hướng tới UI thêm thành viên nhóm
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thêm thành viên (mock)')),
                  );
                },
              ),
              child: ConversationTile(
                c: c,
                // bạn có thể hiển thị dot/badge nếu unread == true
                onTap: () => Navigator.of(context).pushNamed(
                  AppRoutes.chat,
                  arguments: {'conversationId': c.id, 'title': title},
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ===== Menu tác vụ khi long-press 1 hội thoại =====
Future<void> openConversationOptions(
    BuildContext context, {
      required String conversationId,
      required String title,
      required String type,                // 'direct' | 'group'
      required bool muted,
      required bool unread,
      bool canAddMembers = false,
      required ValueChanged<bool> onToggleMute,
      required ValueChanged<bool> onToggleUnread,
      required VoidCallback onDelete,
      required VoidCallback onEnterMultiSelect,
      VoidCallback? onCreateGroupWithUser,
      VoidCallback? onBlockUser,
      VoidCallback? onLeaveGroup,
      VoidCallback? onAddMembers,
    }) async {
  final cs = Theme.of(context).colorScheme;
  final mq = MediaQuery.of(context);
  final hiddenOn = HiddenChatPrefs.isEnabled(conversationId);
  final isDirect = type == 'direct';
  final isGroup  = type == 'group';

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true, // <-- QUAN TRỌNG
    backgroundColor: Colors.transparent,
    builder: (_) {
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(
            icon: muted ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: cs.primary,
            label: muted ? 'Bật thông báo' : 'Tắt thông báo',
            onTap: () { Navigator.pop(context); onToggleMute(!muted); },
          ),
          const Divider(height: 1),
          _tile(
            icon: unread ? Icons.mark_email_read_outlined
                : Icons.mark_email_unread_outlined,
            color: cs.primary,
            label: unread ? 'Bỏ đánh dấu chưa đọc' : 'Đánh dấu chưa đọc',
            onTap: () { Navigator.pop(context); onToggleUnread(!unread); },
          ),
          const Divider(height: 1),
          _tile(
            icon: Icons.checklist_outlined,
            color: cs.primary,
            label: 'Chọn nhiều',
            onTap: () { Navigator.pop(context); onEnterMultiSelect(); },
          ),
          const Divider(height: 1),
          _tile(
            icon: Icons.visibility_off_outlined,
            color: hiddenOn ? Colors.red : cs.primary,
            label: hiddenOn ? 'Tắt ẩn đoạn chat' : 'Ẩn đoạn chat',
            danger: hiddenOn,
            onTap: () async {
              Navigator.pop(context);
              if (!hiddenOn) {
                final pin = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const PinSheet(title: 'Tạo PIN 6 số', confirmMode: true),
                );
                if (pin != null) {
                  HiddenChatPrefs.enableWithPin(conversationId, pin);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã bật Ẩn (PIN 6 số – mock)')),
                  );
                }
              } else {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Tắt ẩn đoạn chat'),
                    content: const Text('Tắt ẩn sẽ xóa PIN hiện tại. Lần bật sau sẽ tạo PIN mới.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tắt')),
                    ],
                  ),
                );
                if (ok == true) {
                  HiddenChatPrefs.disableAndClear(conversationId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã tắt Ẩn & xóa PIN (mock)')),
                  );
                }
              }
            },
          ),
          if (isDirect) ...[
            const Divider(height: 1),
            _tile(
              icon: Icons.groups_outlined,
              color: cs.primary,
              label: 'Tạo nhóm với $title',
              onTap: () { Navigator.pop(context); onCreateGroupWithUser?.call(); },
            ),
            const Divider(height: 1),
            _tile(
              icon: Icons.block_outlined,
              color: Colors.red,
              label: 'Chặn',
              danger: true,
              onTap: () { Navigator.pop(context); onBlockUser?.call(); },
            ),
          ],
          if (isGroup) ...[
            const Divider(height: 1),
            _tile(
              icon: Icons.logout,
              color: Colors.red,
              label: 'Rời nhóm',
              danger: true,
              onTap: () { Navigator.pop(context); onLeaveGroup?.call(); },
            ),
            if (canAddMembers) ...[
              const Divider(height: 1),
              _tile(
                icon: Icons.person_add_alt,
                color: cs.primary,
                label: 'Thêm thành viên',
                onTap: () { Navigator.pop(context); onAddMembers?.call(); },
              ),
            ],
          ],
          const Divider(height: 1),
          _tile(
            icon: Icons.delete_outline,
            color: Colors.red,
            label: 'Xóa',
            danger: true,
            onTap: () { Navigator.pop(context); onDelete(); },
          ),
        ],
      );

      return SafeArea(
        child: Container(
          // bo góc + đổ bóng
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          // giới hạn tối đa 80% chiều cao màn hình
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mq.size.height * 0.80,
            ),
            // cuộn được khi thiếu chỗ
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              child: content,
            ),
          ),
        ),
      );
    },
  );
}

// Helper cho 1 dòng item, nhỏ gọn để đỡ tràn
Widget _tile({
  required IconData icon,
  required Color color,
  required String label,
  required VoidCallback onTap,
  bool danger = false,
}) {
  return ListTile(
    leading: Icon(icon, color: danger ? Colors.red : color),
    minLeadingWidth: 28,
    horizontalTitleGap: 12,
    dense: true,                    // <-- nhỏ gọn
    visualDensity: VisualDensity.compact,
    title: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: danger ? Colors.red : null,
      ),
    ),
    onTap: onTap,
  );
}
