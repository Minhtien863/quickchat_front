import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // ví dụ nhóm "Earlier"
        Text('Earlier', style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListTile(
          leading: const CircleAvatar(backgroundImage: NetworkImage('https://…')),
          title: const Text('Long Hoàng', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Hai bạn giờ đã là bạn bè. Hãy nhắn để chat. · 5 ngày'),
          trailing: const CircleAvatar(radius: 5, backgroundColor: Color(0xFF1976D2)), // dot chưa đọc
          onTap: () {}, // mở chi tiết
        ),
      ],
    );
  }
}
