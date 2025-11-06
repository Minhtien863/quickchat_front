import 'package:flutter/material.dart';

import '../../../widgets/q_app_header.dart';
import '../../../widgets/tokens.dart';
import 'blocked_messages_page.dart';
import 'blocked_calls_page.dart';

class BlockAndHidePage extends StatelessWidget {
  const BlockAndHidePage({super.key});

  // Mở danh sách chặn tin nhắn
  void _openBlockedMessages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockedMessagesPage()),
    );
  }

  // Mở danh sách chặn cuộc gọi
  void _openBlockedCalls(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockedCallsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Chặn và ẩn',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.chat_bubble_outline, color: cs.primary),
                  title: const Text(
                    'Chặn tin nhắn',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Quản lý người bạn đã chặn không cho gửi tin nhắn',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openBlockedMessages(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.call_end_outlined, color: cs.primary),
                  title: const Text(
                    'Chặn cuộc gọi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Quản lý người bạn đã chặn không cho gọi điện',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openBlockedCalls(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
