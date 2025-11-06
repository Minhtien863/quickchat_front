import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';
import 'privacy/block_and_hide_page.dart';

enum BirthdayVisibility { hidden, full, dayMonth }
enum MessagePermission { everyone, friends }
enum CallPermission { everyone, friends, friendsAndKnown }

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Trạng thái mock cho UI
  BirthdayVisibility _birthdayVisibility = BirthdayVisibility.full;
  bool _showOnlineStatus = true;
  bool _showReadReceipts = true;
  MessagePermission _messagePermission = MessagePermission.everyone;
  CallPermission _callPermission = CallPermission.everyone;

  // Lấy text mô tả hiển thị sinh nhật
  String _birthdayVisibilityLabel(BirthdayVisibility v) {
    switch (v) {
      case BirthdayVisibility.hidden:
        return 'Không hiển thị';
      case BirthdayVisibility.full:
        return 'Hiện đầy đủ ngày, tháng, năm';
      case BirthdayVisibility.dayMonth:
        return 'Chỉ hiện ngày, tháng';
    }
  }

  // Lấy text mô tả cho phép nhắn tin
  String _messagePermissionLabel(MessagePermission v) {
    switch (v) {
      case MessagePermission.everyone:
        return 'Mọi người';
      case MessagePermission.friends:
        return 'Chỉ bạn bè';
    }
  }

  // Lấy text mô tả cho phép gọi điện
  String _callPermissionLabel(CallPermission v) {
    switch (v) {
      case CallPermission.everyone:
        return 'Mọi người';
      case CallPermission.friends:
        return 'Chỉ bạn bè';
      case CallPermission.friendsAndKnown:
        return 'Bạn bè và người lạ đã từng liên hệ';
    }
  }

  // Mở page chỉnh quyền hiển thị sinh nhật
  Future<void> _openBirthdayVisibility() async {
    final result = await Navigator.push<BirthdayVisibility>(
      context,
      MaterialPageRoute(
        builder: (_) => _BirthdayVisibilityPage(
          initial: _birthdayVisibility,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _birthdayVisibility = result);
    }
  }

  // Mở bottom sheet chọn quyền nhắn tin
  Future<void> _openMessagePermissionSheet() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showModalBottomSheet<MessagePermission>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black26)],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Cho phép ai có thể nhắn tin cho bạn',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                RadioListTile<MessagePermission>(
                  value: MessagePermission.everyone,
                  groupValue: _messagePermission,
                  title: const Text('Mọi người'),
                  onChanged: (v) => Navigator.pop(context, v),
                ),
                RadioListTile<MessagePermission>(
                  value: MessagePermission.friends,
                  groupValue: _messagePermission,
                  title: const Text('Chỉ bạn bè'),
                  onChanged: (v) => Navigator.pop(context, v),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _messagePermission = result);
    }
  }

  // Mở bottom sheet chọn quyền gọi điện
  Future<void> _openCallPermissionSheet() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showModalBottomSheet<CallPermission>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black26)],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Cho phép ai có thể gọi cho bạn',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                RadioListTile<CallPermission>(
                  value: CallPermission.everyone,
                  groupValue: _callPermission,
                  title: const Text('Mọi người'),
                  onChanged: (v) => Navigator.pop(context, v),
                ),
                RadioListTile<CallPermission>(
                  value: CallPermission.friends,
                  groupValue: _callPermission,
                  title: const Text('Chỉ bạn bè'),
                  onChanged: (v) => Navigator.pop(context, v),
                ),
                RadioListTile<CallPermission>(
                  value: CallPermission.friendsAndKnown,
                  groupValue: _callPermission,
                  title: const Text('Bạn bè và người lạ đã từng liên hệ'),
                  onChanged: (v) => Navigator.pop(context, v),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _callPermission = result);
    }
  }

  // Mở trang chặn và ẩn
  Future<void> _openBlockAndHide() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockAndHidePage()),
    );
  }

  // Build một nhóm section label
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

  // Build một container group items
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
        title: 'Quyền riêng tư',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Cá nhân'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Sinh nhật',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _birthdayVisibilityLabel(_birthdayVisibility),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openBirthdayVisibility,
            ),
          ]),
          _sectionTitle('Trạng thái hoạt động'),
          _groupContainer([
            SwitchListTile(
              value: _showOnlineStatus,
              onChanged: (v) => setState(() => _showOnlineStatus = v),
              title: const Text(
                'Hiện trạng thái truy cập',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Cho phép người khác thấy khi bạn đang trực tuyến hoặc hoạt động gần đây',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              value: _showReadReceipts,
              onChanged: (v) => setState(() => _showReadReceipts = v),
              title: const Text(
                'Hiện trạng thái đã xem',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Hiện "Đã xem" khi bạn đọc tin nhắn. Tắt đi thì bạn cũng không xem được trạng thái đã xem của người khác.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ]),
          _sectionTitle('Liên hệ'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Cho phép nhắn tin',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _messagePermissionLabel(_messagePermission),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openMessagePermissionSheet,
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text(
                'Cho phép gọi điện',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _callPermissionLabel(_callPermission),
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openCallPermissionSheet,
            ),
          ]),
          _sectionTitle('Chặn và ẩn'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Chặn và ẩn',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Quản lý người bị chặn tin nhắn, cuộc gọi và các đoạn chat ẩn',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openBlockAndHide,
            ),
          ]),
        ],
      ),
    );
  }
}

class _BirthdayVisibilityPage extends StatefulWidget {
  final BirthdayVisibility initial;

  const _BirthdayVisibilityPage({super.key, required this.initial});

  @override
  State<_BirthdayVisibilityPage> createState() =>
      _BirthdayVisibilityPageState();
}

class _BirthdayVisibilityPageState extends State<_BirthdayVisibilityPage> {
  late BirthdayVisibility _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  String _label(BirthdayVisibility v) {
    switch (v) {
      case BirthdayVisibility.hidden:
        return 'Không hiển thị';
      case BirthdayVisibility.full:
        return 'Hiện đầy đủ ngày, tháng, năm';
      case BirthdayVisibility.dayMonth:
        return 'Chỉ hiện ngày, tháng';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Hiển thị sinh nhật',
        onBack: () => Navigator.pop(context, _value),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: BirthdayVisibility.values.map((v) {
                return Column(
                  children: [
                    RadioListTile<BirthdayVisibility>(
                      value: v,
                      groupValue: _value,
                      title: Text(_label(v)),
                      onChanged: (nv) {
                        if (nv == null) return;
                        setState(() => _value = nv);
                      },
                    ),
                    if (v != BirthdayVisibility.values.last)
                      const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _value),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.lg),
                  ),
                ),
                child: const Text(
                  'LƯU',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
