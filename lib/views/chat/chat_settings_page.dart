// lib/views/chat/chat_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';
import '../../routes.dart';

/// ===== Lưu trạng thái ẩn + PIN 6 số theo từng conversation (mock/UI) =====
class HiddenChatPrefs {
  static final Map<String, _HiddenState> _map = {}; // conversationId -> state

  static bool isEnabled(String id) => _map[id]?.enabled == true;
  static bool hasPin(String id) => (_map[id]?.pin ?? '').isNotEmpty;

  static void enableWithPin(String id, String pin) {
    _map[id] = _HiddenState(enabled: true, pin: pin);
  }

  static void disableAndClear(String id) {
    _map[id] = _HiddenState(enabled: false, pin: '');
  }

  /// Unlock chỉ kiểm tra PIN, KHÔNG tắt trạng thái ẩn (theo yêu cầu)
  static bool verifyPin(String id, String pin) => _map[id]?.pin == pin;
}

class _HiddenState {
  final bool enabled;
  final String pin;
  _HiddenState({required this.enabled, required this.pin});
}

class ChatSettingsPage extends StatefulWidget {
  final String conversationId;
  final String title;          // display name / tên nhóm
  final String? avatarUrl;
  final String? avatarText;    // fallback chữ cái

  const ChatSettingsPage({
    super.key,
    required this.conversationId,
    required this.title,
    this.avatarUrl,
    this.avatarText,
  });

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  // Mock states
  bool _muted = false;
  bool _readReceipts = true;
  late bool _hiddenEnabled;

  @override
  void initState() {
    super.initState();
    _hiddenEnabled = HiddenChatPrefs.isEnabled(widget.conversationId);
  }

  Future<void> _editAlias() async {
    final c = TextEditingController(text: widget.title);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Biệt danh'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(hintText: 'Nhập biệt danh'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu biệt danh (mock)')),
      );
    }
  }

  void _openSearchInChat() {
    Navigator.pushNamed(
      context,
      AppRoutes.chatSearch,
      arguments: {
        'conversationId': widget.conversationId,
        'title': widget.title,
      },
    );
  }

  void _openCustomize() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tùy chỉnh (mock)')));
  }

  void _openMediaList() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Xem file/media (mock)')));
  }

  void _openPinned() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tin nhắn đã ghim (mock)')));
  }

  Future<void> _shareContact() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Chia sẻ thông tin liên hệ (mock)')));
  }

  Future<void> _createGroupWithUser() async {
    Navigator.pushNamed(context, AppRoutes.createGroup);
  }

  Future<void> _toggleMute(bool v) async {
    setState(() => _muted = v);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(v ? 'Đã tắt thông báo (mock)' : 'Đã bật thông báo (mock)')));
  }

  Future<void> _toggleReadReceipts(bool v) async {
    setState(() => _readReceipts = v);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(v ? 'Đã bật thông báo đã đọc (mock)' : 'Đã tắt thông báo đã đọc (mock)')));
  }

  Future<void> _openMessagePermissions() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Quyền với tin nhắn (mock)')));
  }

  Future<void> _blockUser() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chặn người này?'),
        content: Text('Bạn có chắc muốn chặn ${widget.title}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Chặn')),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã chặn (mock)')));
    }
  }

  Future<void> _report() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo (mock)')));
  }

  /// Bật/tắt Ẩn đoạn chat (PIN 6 số)
  Future<void> _toggleHidden(bool v) async {
    if (v) {
      // Bật: luôn yêu cầu tạo PIN mới
      final pin = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _PinSheet(title: 'Tạo PIN 6 số', confirmMode: true),
      );
      if (pin == null) return; // user hủy
      HiddenChatPrefs.enableWithPin(widget.conversationId, pin);
      setState(() => _hiddenEnabled = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã bật ẩn đoạn chat (PIN 6 số – mock)')),
      );
    } else {
      // Tắt: xác nhận → xóa PIN
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Tắt ẩn đoạn chat'),
          content: const Text('Khi tắt, PIN hiện tại sẽ bị xóa. Lần bật sau sẽ tạo PIN mới.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Tắt')),
          ],
        ),
      );
      if (ok == true) {
        HiddenChatPrefs.disableAndClear(widget.conversationId);
        setState(() => _hiddenEnabled = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tắt ẩn đoạn chat & xóa PIN (mock)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Cài đặt đoạn chat',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          // Avatar + tên (nhỏ)
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundImage: (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty)
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
                      ? Text(
                    (widget.avatarText ?? widget.title).characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 26),
                  )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.xs,
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Phím tắt
          _RowShortcut(
            items: [
              _Shortcut(icon: Icons.badge_outlined, label: 'Biệt danh', onTap: _editAlias),
              _Shortcut(icon: Icons.search, label: 'Tìm kiếm', onTap: _openSearchInChat),
              _Shortcut(icon: Icons.palette_outlined, label: 'Tùy chỉnh', onTap: _openCustomize),
            ],
          ),
          const SizedBox(height: 8),

          // Thông tin đoạn chat
          const _SectionHeader('Thông tin về đoạn chat'),
          _Tile(
            icon: Icons.photo_library_outlined,
            label: 'Xem file phương tiện, file và liên kết',
            onTap: _openMediaList,
          ),
          _Tile(
            icon: Icons.push_pin_outlined,
            label: 'Tin nhắn đã ghim',
            onTap: _openPinned,
          ),

          const SizedBox(height: 8),

          // Hành động
          const _SectionHeader('Hành động'),
          _SwitchTile(
            icon: Icons.notifications_off_outlined,
            label: 'Tắt thông báo về ${widget.title}',
            value: _muted,
            onChanged: _toggleMute,
          ),
          _Tile(
            icon: Icons.groups_outlined,
            label: 'Tạo nhóm chat với ${widget.title}',
            onTap: _createGroupWithUser,
          ),
          _Tile(
            icon: Icons.share_outlined,
            label: 'Chia sẻ thông tin liên hệ',
            onTap: _shareContact,
          ),
          // Ẩn đoạn chat (Switch) — bật: tạo PIN; tắt: xóa PIN
          _SwitchTile(
            icon: Icons.visibility_off_outlined,
            label: 'Ẩn đoạn chat (PIN 6 số)',
            value: _hiddenEnabled,
            onChanged: _toggleHidden,
          ),

          const SizedBox(height: 8),

          // Quyền riêng tư & hỗ trợ
          const _SectionHeader('Quyền riêng tư và hỗ trợ'),
          _SwitchTile(
            icon: Icons.remove_red_eye_outlined,
            label: 'Thông báo đã đọc',
            value: _readReceipts,
            onChanged: _toggleReadReceipts,
          ),
          _Tile(
            icon: Icons.verified_user_outlined,
            label: 'Quyền với tin nhắn',
            onTap: _openMessagePermissions,
          ),
          _Tile(
            icon: Icons.block_outlined,
            label: 'Chặn',
            danger: true,
            onTap: _blockUser,
          ),
          _Tile(
            icon: Icons.report_gmailerrorred_outlined,
            label: 'Báo cáo',
            danger: true,
            onTap: _report,
          ),
        ],
      ),
    );
  }
}

/// ---------- UI bits ----------
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = danger ? Colors.red : const Color(0xFF111827);

    return Column(
      children: [
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, size: 20, color: danger ? Colors.red : cs.primary),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(icon, size: 20, color: cs.primary),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          trailing: Switch(value: value, onChanged: onChanged),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _RowShortcut extends StatelessWidget {
  final List<_Shortcut> items;
  const _RowShortcut({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: items
          .map((e) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: e.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(e.icon, size: 20, color: cs.primary),
                const SizedBox(height: 4),
                Text(
                  e.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}

class _Shortcut {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _Shortcut({required this.icon, required this.label, required this.onTap});
}

/// ===== Bottom Sheet nhập/tạo PIN 6 số =====
class _PinSheet extends StatefulWidget {
  final String title;
  final bool confirmMode; // true: tạo PIN (nhập + xác nhận)

  const _PinSheet({
    required this.title,
    this.confirmMode = false,
  });

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  bool get _ok1 => _c1.text.length == 6;
  bool get _ok2 => _c2.text.length == 6;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _PinField(controller: _c1, label: widget.confirmMode ? 'Nhập PIN' : 'PIN 6 số'),
            if (widget.confirmMode) ...[
              const SizedBox(height: 8),
              _PinField(controller: _c2, label: 'Nhập lại PIN'),
            ],
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!_ok1 || (widget.confirmMode && !_ok2)) return;
                  if (widget.confirmMode && _c1.text != _c2.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN xác nhận không khớp')),
                    );
                    return;
                  }
                  Navigator.pop(context, _c1.text);
                },
                child: Text(widget.confirmMode ? 'Lưu PIN' : 'Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 6,
      obscureText: true,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: '••••••',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
