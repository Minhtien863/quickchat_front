import 'package:flutter/material.dart';
import '../../../routes.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Minh Tiến'),
            subtitle: const Text('tien@example.com'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile, arguments: {'userId': 'me'}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Bảo mật & PIN'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('Thiết bị & phiên đăng nhập'),
            onTap: () {/* TODO */},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
