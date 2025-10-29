import 'package:flutter/material.dart';
import '../../services/service_registry.dart';
import '../../services/contacts_service.dart';

class FriendInvitesPage extends StatefulWidget {
  const FriendInvitesPage({super.key});
  @override
  State<FriendInvitesPage> createState() => _FriendInvitesPageState();
}

class _FriendInvitesPageState extends State<FriendInvitesPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Future<List<FriendInviteDTO>> _receivedFut;
  late Future<List<FriendInviteDTO>> _sentFut;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    _receivedFut = Services.contacts.listFriendInvites();
    _sentFut     = Services.contacts.listSentFriendInvites();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời kết bạn'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [Tab(text: 'Đã nhận'), Tab(text: 'Đã gửi')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _InvitesList(
            future: _receivedFut,
            emptyText: 'Chưa có lời mời nào',
            actionBuilder: (iv) => Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () async { await Services.contacts.declineFriendInvite(iv.id); if (!mounted) return; setState(_reload); },
                    child: const Text('TỪ CHỐI'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () async { await Services.contacts.acceptFriendInvite(iv.id); if (!mounted) return; setState(_reload); },
                    child: const Text('ĐỒNG Ý'),
                  ),
                ),
              ],
            ),
          ),
          _InvitesList(
            future: _sentFut,
            emptyText: 'Bạn chưa gửi lời mời nào',
            actionBuilder: (iv) => Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async { await Services.contacts.cancelSentFriendInvite(iv.id); if (!mounted) return; setState(_reload); },
                child: const Text('THU HỒI'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitesList extends StatelessWidget {
  final Future<List<FriendInviteDTO>> future;
  final String emptyText;
  final Widget Function(FriendInviteDTO) actionBuilder;
  const _InvitesList({required this.future, required this.emptyText, required this.actionBuilder});

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays} ngày trước';
    if (d.inHours >= 1) return '${d.inHours} giờ trước';
    if (d.inMinutes >= 1) return '${d.inMinutes} phút trước';
    return 'Vừa xong';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FriendInviteDTO>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final list = snap.data ?? [];
        if (list.isEmpty) return Center(child: Text(emptyText));
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final iv = list[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  CircleAvatar(radius: 24, child: Text(iv.displayName.characters.first.toUpperCase())),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(iv.displayName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text('Muốn kết bạn · ${_timeAgo(iv.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 200, child: actionBuilder(iv)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
