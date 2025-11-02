import 'package:flutter/material.dart';
import '../models/user_lite.dart'; // nếu file này ở lib/models/user_lite.dart

class QUserResultTile extends StatelessWidget {
  final UserLite user;
  final VoidCallback? onInvite;
  const QUserResultTile({super.key, required this.user, this.onInvite});

  @override
  Widget build(BuildContext context) {
    final title = user.displayName ?? user.handle ?? 'Người dùng';
    final subtitle = user.handle != null
        ? '@${user.handle}'
        : (user.email ?? (user.phone ?? ''));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF3F4F6),
                backgroundImage: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? null
                    : NetworkImage(user.avatarUrl!),
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person_outline, color: Color(0xFF9CA3AF), size: 28)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            user.invited
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF6B7280)),
                SizedBox(width: 6),
                Text('Đã gửi',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
              ]),
            )
                : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onInvite,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: user.sending
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.person_add_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Kết bạn',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
