import 'package:flutter/material.dart';

import '../../services/contacts_service.dart';
import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';
import '../../services/service_registry.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileDTO profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameC;
  late TextEditingController _handleC;
  late TextEditingController _bioC;
  late TextEditingController _phoneC;
  late TextEditingController _emailC;

  DateTime? _birthday;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameC   = TextEditingController(text: widget.profile.displayName);
    _handleC = TextEditingController(text: widget.profile.handle ?? '');
    _bioC    = TextEditingController(text: widget.profile.bio ?? '');
    _phoneC  = TextEditingController(text: widget.profile.phone ?? '');
    _emailC  = TextEditingController(text: widget.profile.email ?? '');
    _birthday = widget.profile.birthday;
  }


  @override
  void dispose() {
    _nameC.dispose();
    _handleC.dispose();
    _bioC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  // Chọn ngày sinh
  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 80);
    final last = DateTime(now.year - 10, now.month, now.day);
    final init = _birthday ?? DateTime(now.year - 20, now.month, now.day);

    final d = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );
    if (d != null && mounted) {
      setState(() => _birthday = d);
    }
  }

  // Định dạng ngày
  String _formatBirthday(DateTime? d) {
    if (d == null) return 'Thêm';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  // Lưu backend
  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok || _saving) return;

    setState(() => _saving = true);
    try {
      final updated = await Services.contacts.updateMyProfile(
        displayName: _nameC.text.trim(),
        bio: _bioC.text.trim().isEmpty ? null : _bioC.text.trim(),
        phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
        birthday: _birthday,
      );

      if (!mounted) return;
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Sửa trang cá nhân',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            const SizedBox(height: 8),

            const _SectionLabel('Tên bạn'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tên hiển thị',
                ),
                maxLength: 60,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Vui lòng nhập tên';
                  if (t.length < 2) return 'Tên quá ngắn';
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            const _SectionLabel('Tên người dùng (@handle)'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: _handleC,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixText: '@',
                  hintText: 'nhập tên người dùng',
                ),
                maxLength: 32,
                enabled: false,
              ),
            ),

            const SizedBox(height: 16),

            const _SectionLabel('Số điện thoại'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: _phoneC,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Thêm số điện thoại',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 20,
              ),
            ),

            const SizedBox(height: 16),

            const _SectionLabel('Email'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: _emailC,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Thêm email',
                ),
                keyboardType: TextInputType.emailAddress,
                maxLength: 80,
                enabled: false, // <-- chưa cho đổi email
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return null;
                  if (!t.contains('@') || !t.contains('.')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            const _SectionLabel('Câu giới thiệu'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _bioC,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Viết vài dòng về bạn…',
                    ),
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bạn có thể giới thiệu đôi chút về mình. Quyền hiển thị sẽ cấu hình ở phần riêng tư sau.',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const _SectionLabel('Sinh nhật'),
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Sinh nhật'),
                    subtitle: Text(
                      _birthday == null
                          ? 'Thêm ngày sinh'
                          : _formatBirthday(_birthday),
                    ),
                    onTap: _pickBirthday,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  if (_birthday != null) const Divider(height: 1),
                  if (_birthday != null)
                    ListTile(
                      title: const Text(
                        'Xóa bỏ sinh nhật',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => setState(() => _birthday = null),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
            ),
            child: _saving
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'LƯU THAY ĐỔI',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0A84FF),
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
