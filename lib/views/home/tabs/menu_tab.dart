import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../settings/account_security_page.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  // build tile cài đặt chung
  Widget _settingsTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF111827)),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: onTap ??
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label (mock)')),
              );
            },
      ),
    );
  }

  // build chính
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const SizedBox(height: 12),

          // Hồ sơ của tôi
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.profile,
              arguments: {'userId': 'me'},
            ),
            child: Row(
              children: const [
                CircleAvatar(child: Icon(Icons.person)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hồ sơ của tôi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Xem và chỉnh sửa trang cá nhân',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tài khoản và bảo mật
          _settingsTile(
            context,
            icon: Icons.security_outlined,
            label: 'Tài khoản và bảo mật',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AccountSecurityPage(),
                ),
              );
            },
          ),

          // Quyền riêng tư
          _settingsTile(
            context,
            icon: Icons.lock_outline,
            label: 'Quyền riêng tư',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Quyền riêng tư (mock)')),
              );
            },
          ),
        ],
      ),
    );
  }
}
