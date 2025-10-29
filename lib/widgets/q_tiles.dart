import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/contacts_service.dart';
import 'q_avatar.dart';

class ConversationTile extends StatelessWidget {
  final ConversationDTO c;
  final VoidCallback? onTap;
  const ConversationTile({super.key, required this.c, this.onTap});

  @override
  Widget build(BuildContext context) {
    final last = c.lastMessage;
    return ListTile(
      leading: QAvatar(label: c.title, online: false, size: 48),
      title: Text(c.title ?? '(Không tên)', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(last?.text ?? '[${last?.type ?? '...'}]', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: c.unreadCount > 0
          ? CircleAvatar(radius: 12, child: Text('${c.unreadCount}', style: const TextStyle(fontSize: 12)))
          : null,
      onTap: onTap,
    );
  }
}

class FriendTile extends StatelessWidget {
  final FriendDTO f;
  final VoidCallback? onTap;
  const FriendTile({super.key, required this.f, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: QAvatar(label: f.displayName, online: f.online),
      title: Text(f.displayName),
      trailing: Wrap(spacing: 6, children: const [
        Icon(Icons.call_outlined, size: 20),
        Icon(Icons.videocam_outlined, size: 20),
      ]),
      onTap: onTap,
    );
  }
}

class GroupTile extends StatelessWidget {
  final GroupDTO g;
  final VoidCallback? onTap;
  const GroupTile({super.key, required this.g, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: QAvatar(label: g.title),
      title: Text(g.title),
      subtitle: Text('Thành viên: ${g.memberCount}'),
      trailing: g.muted ? const Icon(Icons.notifications_off, size: 18) : null,
      onTap: onTap,
    );
  }
}
