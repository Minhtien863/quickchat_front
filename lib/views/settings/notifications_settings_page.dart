import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';

import 'group_chat_notifications_page.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  // Trạng thái mock cho UI
  bool _directChatEnabled = true;
  bool _callIncomingEnabled = true;

  // Mở trang cài đặt thông báo nhóm
  void _openGroupChatNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GroupChatNotificationsPage(),
      ),
    );
  }

  // Section title
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  // Container group
  Widget _groupContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  // Build chính
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Thông báo',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Trò chuyện 2 người'),
          _groupContainer([
            SwitchListTile(
              value: _directChatEnabled,
              onChanged: (v) {
                setState(() => _directChatEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v
                          ? 'Đã bật báo tin nhắn mới từ trò chuyện 2 người (mock)'
                          : 'Đã tắt báo tin nhắn mới từ trò chuyện 2 người (mock)',
                    ),
                  ),
                );
              },
              title: const Text(
                'Báo tin nhắn mới từ trò chuyện 2 người',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Hiển thị thông báo khi có tin nhắn mới trong các cuộc trò chuyện 1:1',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ]),
          _sectionTitle('Cuộc gọi'),
          _groupContainer([
            SwitchListTile(
              value: _callIncomingEnabled,
              onChanged: (v) {
                setState(() => _callIncomingEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v
                          ? 'Đã bật báo cuộc gọi đến (mock)'
                          : 'Đã tắt báo cuộc gọi đến (mock)',
                    ),
                  ),
                );
              },
              title: const Text(
                'Báo cuộc gọi đến',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Nhận thông báo khi có cuộc gọi đến trên QuickChat',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ]),

          _sectionTitle('Trò chuyện nhóm'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Báo tin nhắn mới từ nhóm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Quản lý thông báo cho tất cả nhóm và từng nhóm cụ thể',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openGroupChatNotifications,
            ),
          ]),
        ],
      ),
    );
  }
}
