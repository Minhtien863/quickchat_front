import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';

enum GroupMuteChoice {
  oneHour,
  fourHours,
  untilMorning,
  untilTurnedOn,
}

class GroupChatNotificationsPage extends StatefulWidget {
  const GroupChatNotificationsPage({super.key});

  @override
  State<GroupChatNotificationsPage> createState() =>
      _GroupChatNotificationsPageState();
}

class _GroupChatNotificationsPageState
    extends State<GroupChatNotificationsPage> {
  // Trạng thái tổng cho nhóm
  bool _groupsEnabled = true;

  // Mock danh sách nhóm đã tham gia
  final List<_GroupItem> _groups = [
    _GroupItem(id: 'g1', name: 'Lớp CNTT K15', lastDesc: 'Sinh hoạt CLB'),
    _GroupItem(id: 'g2', name: 'Bạn thân 3 người', lastDesc: 'Hẹn đi chơi'),
    _GroupItem(id: 'g3', name: 'Dự án tốt nghiệp', lastDesc: 'Trao đổi bài'),
  ];

  // Map trạng thái bật/tắt cho từng nhóm
  final Map<String, bool> _groupEnabled = {};
  // Map text mô tả mute cho từng nhóm (mock)
  final Map<String, String> _groupMuteNote = {};

  // Lấy trạng thái enable hiện tại của nhóm
  bool _isGroupEnabled(String id) {
    if (_groupEnabled.containsKey(id)) return _groupEnabled[id]!;
    return true;
  }

  // Set trạng thái enable cho nhóm
  void _setGroupEnabled(String id, bool enabled) {
    _groupEnabled[id] = enabled;
  }

  // Mở popup khi tắt thông báo nhóm
  Future<bool> _showMuteDialog(String groupName) async {
    final choice = await showDialog<GroupMuteChoice>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tắt thông báo trò chuyện?'),
          content: Text(
            'Chọn khoảng thời gian tắt thông báo cho nhóm "$groupName".',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, GroupMuteChoice.oneHour),
              child: const Text('Trong 1 giờ'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, GroupMuteChoice.fourHours),
              child: const Text('Trong 4 giờ'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, GroupMuteChoice.untilMorning),
              child: const Text('Đến 8 giờ sáng'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, GroupMuteChoice.untilTurnedOn),
              child: const Text('Cho đến khi được mở lại'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );

    if (choice == null) return false;

    String note;
    switch (choice) {
      case GroupMuteChoice.oneHour:
        note = 'Đã tắt trong 1 giờ (mock)';
        break;
      case GroupMuteChoice.fourHours:
        note = 'Đã tắt trong 4 giờ (mock)';
        break;
      case GroupMuteChoice.untilMorning:
        note = 'Đã tắt đến 8 giờ sáng (mock)';
        break;
      case GroupMuteChoice.untilTurnedOn:
        note = 'Đã tắt cho đến khi được mở lại (mock)';
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$note cho nhóm "$groupName"')),
      );
    }
    return true;
  }

  // Xử lý bật/tắt cho từng nhóm
  Future<void> _onToggleGroup(_GroupItem g, bool newValue) async {
    if (newValue) {
      setState(() {
        _setGroupEnabled(g.id, true);
        _groupMuteNote.remove(g.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã bật thông báo cho nhóm "${g.name}" (mock)'),
        ),
      );
      return;
    }

    final ok = await _showMuteDialog(g.name);
    if (!ok) {
      setState(() {
        _setGroupEnabled(g.id, true);
      });
      return;
    }

    setState(() {
      _setGroupEnabled(g.id, false);
      _groupMuteNote[g.id] = 'Đang tắt thông báo (mock)';
    });
  }

  // Section title
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

  // Container group
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

  // Build item nhóm
  Widget _buildGroupTile(_GroupItem g) {
    final cs = Theme.of(context).colorScheme;
    final enabled = _isGroupEnabled(g.id);
    final note = _groupMuteNote[g.id];

    return SwitchListTile(
      value: enabled,
      onChanged: _groupsEnabled
          ? (v) {
        _onToggleGroup(g, v);
      }
          : null,
      title: Text(
        g.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        note ?? (g.lastDesc ?? ''),
        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
      ),
    );
  }

  // Build chính
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Tin nhắn mới từ nhóm',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Cài đặt chung'),
          _groupContainer([
            SwitchListTile(
              value: _groupsEnabled,
              onChanged: (v) {
                setState(() => _groupsEnabled = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v
                          ? 'Đã bật thông báo tin nhắn nhóm (mock)'
                          : 'Đã tắt toàn bộ thông báo tin nhắn nhóm (mock)',
                    ),
                  ),
                );
              },
              title: const Text(
                'Báo tin nhắn mới từ nhóm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Bật/tắt thông báo cho tất cả nhóm bạn tham gia',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ),
          ]),
          _sectionTitle('Nhóm đã tham gia'),
          _groupContainer(
            _groups
                .map((g) => Column(
              children: [
                _buildGroupTile(g),
                if (g != _groups.last) const Divider(height: 1),
              ],
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _GroupItem {
  final String id;
  final String name;
  final String? lastDesc;

  _GroupItem({
    required this.id,
    required this.name,
    this.lastDesc,
  });
}
