import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import 'call_ringtone_page.dart';

enum CallPermission {
  everyone,
  friendsAndKnown,
  friends,
}

class CallSettingsPage extends StatefulWidget {
  const CallSettingsPage({super.key});

  @override
  State<CallSettingsPage> createState() => _CallSettingsPageState();
}

class _CallSettingsPageState extends State<CallSettingsPage> {
  // build state
  bool _notifyIncomingCalls = true;
  CallPermission _permission = CallPermission.everyone;

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

  // build permission label
  String _permissionLabel(CallPermission p) {
    switch (p) {
      case CallPermission.everyone:
        return 'Mọi người';
      case CallPermission.friendsAndKnown:
        return 'Bạn bè và người lạ đã từng liên hệ';
      case CallPermission.friends:
        return 'Chỉ bạn bè';
    }
  }

  // build permission bottom sheet
  Future<void> _pickPermission() async {
    final cs = Theme.of(context).colorScheme;

    final selected = await showModalBottomSheet<CallPermission>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cho phép gọi điện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _permissionTile(CallPermission.everyone),
                const Divider(height: 1),
                _permissionTile(CallPermission.friendsAndKnown),
                const Divider(height: 1),
                _permissionTile(CallPermission.friends),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _permission = selected);
    }
  }

  // build permission tile
  Widget _permissionTile(CallPermission value) {
    final selected = _permission == value;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        _permissionLabel(value),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }

  // build main
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Cài đặt cuộc gọi',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Âm thanh'),
          _groupContainer([
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text(
                'Nhạc chuông',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Chọn âm thanh cho cuộc gọi đến',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CallRingtonePage(),
                  ),
                );
              },
            ),
          ]),

          _sectionTitle('Cuộc gọi'),
          _groupContainer([
            SwitchListTile(
              title: const Text(
                'Báo cuộc gọi đến',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Hiển thị thông báo và đổ chuông khi có cuộc gọi đến',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              value: _notifyIncomingCalls,
              onChanged: (v) {
                setState(() => _notifyIncomingCalls = v);
              },
            ),
          ]),

          _sectionTitle('Quyền riêng tư'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Cho phép gọi điện',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _permissionLabel(_permission),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickPermission,
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text(
                'Chặn cuộc gọi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Quản lý những người bạn đã chặn cuộc gọi',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Chặn cuộc gọi (mock) – dùng lại trang chặn tương tự chặn tin nhắn',
                    ),
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
