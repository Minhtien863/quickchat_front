// lib/views/profile/profile_page.dart
import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../services/contacts_service.dart';
import '../../services/service_registry.dart';
import '../../widgets/tokens.dart';
import 'edit_profile_page.dart';
import '../../widgets/media_picker_sheet.dart';

class ProfilePage extends StatefulWidget {
  final String userId; // 'me' => hồ sơ của chính mình

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfileDTO> _future;
  bool _mockIsFriend = false;

  bool get _isMe => widget.userId == 'me';

  @override
  void initState() {
    super.initState();
    _future = _isMe
        ? Services.contacts.myProfile()
        : Services.contacts.getProfile(widget.userId);
  }

  String _formatBirthday(DateTime? d) {
    if (d == null) return 'Chưa cập nhật';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Future<void> _openAvatarPicker() async {
    await showMediaPickerSheet(
      context,
      onTakePhoto: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chụp ảnh (mock)')),
        );
      },
      onTapMockImage: (i) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chọn ảnh thứ $i (mock)')),
        );
      },
    );
  }

  Future<void> _onHeaderMenuSelected(
      _HeaderMenuAction a,
      UserProfileDTO p,
      ) async {
    switch (a) {
      case _HeaderMenuAction.editInfo:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(profile: p),
          ),
        );
        if (result is Map && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã lưu thông tin (mock)')),
          );
        }
        break;

      case _HeaderMenuAction.setAvatar:
        await _openAvatarPicker();
        break;

      case _HeaderMenuAction.shareContact:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chia sẻ liên lạc (mock)')),
        );
        break;

      case _HeaderMenuAction.block:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chặn người dùng (mock)')),
        );
        break;

      case _HeaderMenuAction.editContact:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sửa liên lạc (mock)')),
        );
        break;

      case _HeaderMenuAction.deleteContact:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa liên lạc (mock)')),
        );
        break;
    }
  }

  Widget _buildHeader(UserProfileDTO p) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2DAAE1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              PopupMenuButton<_HeaderMenuAction>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (a) => _onHeaderMenuSelected(a, p),
                itemBuilder: (_) {
                  if (_isMe) {
                    return const [
                      PopupMenuItem(
                        value: _HeaderMenuAction.editInfo,
                        child: Text('Sửa thông tin'),
                      ),
                      PopupMenuItem(
                        value: _HeaderMenuAction.setAvatar,
                        child: Text('Đặt ảnh đại diện'),
                      ),
                    ];
                  } else {
                    return const [
                      PopupMenuItem(
                        value: _HeaderMenuAction.shareContact,
                        child: Text('Chia sẻ liên lạc'),
                      ),
                      PopupMenuItem(
                        value: _HeaderMenuAction.block,
                        child: Text('Chặn người dùng'),
                      ),
                      PopupMenuItem(
                        value: _HeaderMenuAction.editContact,
                        child: Text('Sửa liên lạc'),
                      ),
                      PopupMenuItem(
                        value: _HeaderMenuAction.deleteContact,
                        child: Text('Xóa liên lạc'),
                      ),
                    ];
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withOpacity(.15),
            child: Text(
              p.displayName.characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'trực tuyến',
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          if (!_isMe)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(.7)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chat,
                        arguments: {
                          'conversationId': p.id,
                          'title': p.displayName,
                        },
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Nhắn tin'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _mockIsFriend = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _mockIsFriend
                                ? 'Gọi (mock)'
                                : 'Gửi lời mời kết bạn (mock)',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      _mockIsFriend
                          ? Icons.call_outlined
                          : Icons.person_add_outlined,
                    ),
                    label: Text(_mockIsFriend ? 'Gọi' : 'Kết bạn'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBody(UserProfileDTO p) {
    final tiles = <Widget>[];

    tiles.add(
      ListTile(
        title: Text(
          '@${p.handle}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: const Text('Tên người dùng'),
      ),
    );

    if (_isMe || p.birthday != null) {
      if (tiles.isNotEmpty) tiles.add(const Divider(height: 1));
      tiles.add(
        ListTile(
          title: Text(
            _formatBirthday(p.birthday),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Sinh nhật'),
        ),
      );
    }

    if (_isMe || (p.phone?.isNotEmpty ?? false)) {
      if (tiles.isNotEmpty) tiles.add(const Divider(height: 1));
      tiles.add(
        ListTile(
          title: Text(
            _isMe
                ? (p.phone?.isNotEmpty == true
                ? p.phone!
                : 'Thêm số điện thoại')
                : (p.phone ?? ''),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Số điện thoại'),
        ),
      );
    }

    if (_isMe || (p.email?.isNotEmpty ?? false)) {
      if (tiles.isNotEmpty) tiles.add(const Divider(height: 1));
      tiles.add(
        ListTile(
          title: Text(
            _isMe
                ? (p.email?.isNotEmpty == true ? p.email! : 'Thêm email')
                : (p.email ?? ''),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Email'),
        ),
      );
    }

    final hasBio = p.bio?.isNotEmpty == true;
    if (_isMe || hasBio) {
      if (tiles.isNotEmpty) tiles.add(const Divider(height: 1));
      tiles.add(
        ListTile(
          title: Text(
            _isMe
                ? (hasBio ? p.bio! : 'Thêm vài dòng về bản thân')
                : (p.bio ?? ''),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text('Giới thiệu'),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF7F8FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isMe)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openAvatarPicker,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        color: Color(0xFF1F2933),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đặt ảnh đại diện',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isMe) Gaps.sm,
            const Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: tiles),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileDTO>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = snap.data!;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          body: Column(
            children: [
              _buildHeader(p),
              Expanded(child: _buildBody(p)),
            ],
          ),
        );
      },
    );
  }
}

enum _HeaderMenuAction {
  editInfo,
  setAvatar,
  shareContact,
  block,
  editContact,
  deleteContact,
}
