import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/service_registry.dart';
import '../../services/contacts_service.dart';
import '../../widgets/q_app_header.dart';
import '../../models/user_lite.dart';

// widgets gom vào /widgets với tên q_*.dart
import '../../widgets/q_search_pill.dart';
import '../../widgets/q_hint_chips.dart';
import '../../widgets/q_user_result_tile.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});
  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  bool _loading = false;
  List<UserLite> _results = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _isEmail => RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")
      .hasMatch(_c.text.trim());
  bool get _isPhone => RegExp(r"^\+?[0-9]{9,15}$")
      .hasMatch(_c.text.trim().replaceAll(' ', ''));
  bool get _isHandle => RegExp(r"^@[a-z0-9_\.]{3,30}$")
      .hasMatch(_c.text.trim());

  IconData get _prefixIcon {
    if (_isEmail) return Icons.email_outlined;
    if (_isPhone) return Icons.phone_outlined;
    if (_isHandle) return Icons.alternate_email;
    return Icons.search;
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 240), () async {
      if (v.trim().isEmpty) {
        setState(() => _results = []);
        return;
      }
      setState(() => _loading = true);
      try {
        final rs = await Services.contacts.searchUsers(q: v.trim());
        setState(() => _results = rs);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  Future<void> _sendInvite(UserLite u) async {
    setState(() => u.sending = true);
    try {
      await Services.contacts.sendFriendInvite(userId: u.id);
      setState(() => u.invited = true);
    } finally {
      if (mounted) setState(() => u.sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: QAppHeader.plain(title: 'Thêm bạn', onBack: () => Navigator.pop(context)),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QSearchPill(
              controller: _c,
              focusNode: _focus,
              prefixIcon: _prefixIcon,
              onChanged: _onChanged,
              onClear: () { _c.clear(); _onChanged(''); },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: QHintChips.defaults(),
          ),
          const SizedBox(height: 24),

          if (_loading) const _Loading(),
          if (!_loading && _results.isEmpty && _c.text.isNotEmpty) const _EmptyState(),

          if (!_loading && _results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final u = _results[i];
                  return QUserResultTile(
                    user: u,
                    onInvite: u.sending ? null : () => _sendInvite(u),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: const [
          SizedBox(width: 32, height: 32,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 16),
          Text('Đang tìm kiếm...', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: QAppHeader.plain(
          title: 'Thêm bạn',               // hoặc 'Lời mời kết bạn'
          onBack: () => Navigator.pop(context),
        ),
        body:
      Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: const [
          CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFFF3F4F6),
            child: Icon(Icons.person_search_outlined, size: 40, color: Color(0xFFD1D5DB)),
          ),
          SizedBox(height: 16),
          Text('Không tìm thấy kết quả',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          SizedBox(height: 6),
          Text('Thử tìm kiếm với từ khóa khác',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
        ],
      ),
      )
    );
  }
}
