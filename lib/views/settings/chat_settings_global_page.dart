import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import 'hidden_chats_settings_page.dart';

class ChatSettingsGlobalPage extends StatelessWidget {
  const ChatSettingsGlobalPage({super.key});

  // build section title
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

  // build group container
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Cài đặt tin nhắn',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Quyền riêng tư'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Chặn tin nhắn',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Xem và quản lý những người bạn đã chặn nhắn tin',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: điều hướng sang trang danh sách chặn tin nhắn
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chặn tin nhắn (mock) – sẽ nối với trang chặn sau'),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text(
                'Ẩn trò chuyện',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Đổi mã PIN, xóa mã PIN và dữ liệu trò chuyện đã ẩn',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HiddenChatsSettingsPage(),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
