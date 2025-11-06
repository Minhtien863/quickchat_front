import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Cài đặt',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _SectionHeader('Tài khoản'),
          _SettingsTile(
            icon: Icons.security_outlined,
            label: 'Tài khoản và bảo mật',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.accountSecurity),
          ),
          const SizedBox(height: 4),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Quyền riêng tư',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.privacySettings),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Hoạt động'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Thông báo',
            onTap: () => Navigator.pushNamed(
                context, AppRoutes.notificationsSettings),
          ),
          _SettingsTile(
            icon: Icons.chat_bubble_outline,
            label: 'Tin nhắn',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.chatSettingsGlobal),
          ),
          _SettingsTile(
            icon: Icons.call_outlined,
            label: 'Cuộc gọi',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.callSettings),
          ),
          const SizedBox(height: 16),
          _SectionHeader('Hiển thị'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            label: 'Giao diện và ngôn ngữ',
            onTap: () => Navigator.pushNamed(
                context, AppRoutes.appearanceLanguage),
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.logout,
            label: 'Đăng xuất',
            danger: true,
            onTap: () {
              // sau nối backend sẽ xử lý đăng xuất thật
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signIn,
                    (r) => false,
              );
            },
          ),
        ],
      ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : const Color(0xFF111827);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: danger ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
