import 'package:flutter/material.dart';
import '../../services/service_registry.dart';
import '../../services/contacts_service.dart';
import '../../routes.dart';

class ProfilePage extends StatefulWidget {
  final String userId; // truyền 'me' để xem hồ sơ của tôi
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfileDTO> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.userId == 'me'
        ? Services.contacts.myProfile()
        : Services.contacts.getProfile(widget.userId);
  }

  String _formatBirthday(DateTime? d) {
    if (d == null) return 'Chưa cập nhật';
    // dd/MM/yyyy
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: FutureBuilder<UserProfileDTO>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                CircleAvatar(radius: 44, child: Text(p.displayName.characters.first.toUpperCase())),
                const SizedBox(height: 12),
                Text(p.displayName, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('@${p.handle}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 16),

                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cake_outlined),
                        title: const Text('Ngày sinh'),
                        subtitle: Text(_formatBirthday(p.birthday)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Giới thiệu'),
                        subtitle: Text(p.bio?.isNotEmpty == true ? p.bio! : 'Chưa cập nhật'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Hành động
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.chat,
                          arguments: {'conversationId': p.id, 'title': p.displayName},
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Nhắn tin'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {}, // TODO: Gọi/Hẹn gặp...
                        icon: const Icon(Icons.call_outlined),
                        label: const Text('Gọi'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
