// lib/views/settings/account_security_page.dart
import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../services/contacts_service.dart';
import '../../services/service_registry.dart';
import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  late Future<UserProfileDTO> _future;
  bool _twoFactor = false; // mock

  // load hồ sơ
  @override
  void initState() {
    super.initState();
    _future = Services.contacts.myProfile();
  }

  // format phone/email
  String _phoneText(String? p) {
    if (p == null || p.isEmpty) return 'Chưa cập nhật';
    return p;
  }

  String _emailText(String? e) {
    if (e == null || e.isEmpty) return 'Chưa liên kết';
    return e;
  }

  // mở trang hồ sơ cá nhân
  void _openMyProfile() {
    Navigator.of(context).pushNamed(
      AppRoutes.profile,
      arguments: {'userId': 'me'},
    );
  }

  // đổi trạng thái bảo mật 2 lớp
  Future<void> _toggle2FA(bool v) async {
    setState(() => _twoFactor = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          v ? 'Đã bật bảo mật 2 lớp (mock)' : 'Đã tắt bảo mật 2 lớp (mock)',
        ),
      ),
    );
  }

  // mở chỉnh sửa mật khẩu (mock)
  void _openPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu (mock)')),
    );
  }

  // xoá tài khoản (mock)
  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Bạn có chắc muốn xóa tài khoản? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu xóa tài khoản (mock)')),
      );
    }
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
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: QAppHeader.plain(
            title: 'Tài khoản và bảo mật',
            onBack: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFFF7F8FA),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _SectionHeader('Tài khoản'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          p.displayName.characters.first.toUpperCase(),
                        ),
                      ),
                      title: const Text('Thông tin cá nhân'),
                      subtitle: Text(p.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openMyProfile,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Số điện thoại'),
                      subtitle: Text(_phoneText(p.phone)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.editPhone, arguments: {
                          'currentPhone': p.phone,
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(_emailText(p.email)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.editEmail, arguments: {
                          'currentEmail': p.email,
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const _SectionHeader('Đăng nhập & bảo mật'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.shield_outlined),
                      title: const Text('Bảo mật 2 lớp'),
                      subtitle: const Text(
                        'Thêm hình thức xác nhận khi đăng nhập trên thiết bị mới',
                      ),
                      value: _twoFactor,
                      onChanged: _toggle2FA,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Mật khẩu'),
                      subtitle: const Text('Đã đặt mật khẩu đăng nhập'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openPassword,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const _SectionHeader('Khác'),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Xóa tài khoản',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: _deleteAccount,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
