import 'package:flutter/material.dart';

import '../../../widgets/q_app_header.dart';

class BlockedCallsPage extends StatelessWidget {
  const BlockedCallsPage({super.key});

  // Mock danh sách người bị chặn cuộc gọi
  List<Map<String, String>> _mockBlocked() {
    return [
      {'name': 'Nguyễn C', 'handle': '@nguyenc'},
      {'name': 'Trần D', 'handle': '@trand'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _mockBlocked();
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Chặn cuộc gọi',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: data.isEmpty
          ? const Center(
        child: Text('Bạn chưa chặn ai khỏi việc gọi cho bạn.'),
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
