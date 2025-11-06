import 'package:flutter/material.dart';

import '../../../widgets/q_app_header.dart';

class BlockedMessagesPage extends StatelessWidget {
  const BlockedMessagesPage({super.key});

  // Mock danh sách người bị chặn tin nhắn
  List<Map<String, String>> _mockBlocked() {
    return [
      {'name': 'Nguyễn A', 'handle': '@nguyena'},
      {'name': 'Trần B', 'handle': '@tranb'},
      {'name': 'User lạ', 'handle': '@random'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _mockBlocked();
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Chặn tin nhắn',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: data.isEmpty
          ? const Center(
        child: Text('Bạn chưa chặn ai khỏi việc gửi tin nhắn.'),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final u = data[i];
          final name = u['name'] ?? '';
          final handle = u['handle'] ?? '';
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  name.isNotEmpty
                      ? name.characters.first.toUpperCase()
                      : '?',
                ),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(handle),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bỏ chặn $name (mock)'),
                    ),
                  );
                },
                child: const Text('BỎ CHẶN'),
              ),
            ),
          );
        },
      ),
    );
  }
}
