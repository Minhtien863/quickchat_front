// lib/views/contacts/tabs/contacts_tab.dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../services/contacts_service.dart';
import '../../../services/service_registry.dart';
import '../../../widgets/q_section_header.dart';
import '../../../widgets/tokens.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});
  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // ===== State =====
  FriendsFilter _filter = FriendsFilter.all;
  GroupSort _groupSort = GroupSort.activity;

  // cache dữ liệu để lọc local
  List<FriendDTO> _friendsAll = [];
  List<GroupDTO> _groupsAll = [];

  bool _loadingFriends = true;
  bool _loadingGroups = true;

  late Future<int> _invitesCountFuture;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loadingFriends = true;
      _loadingGroups  = true;
    });
    final f1 = Services.contacts.listFriends();
    final f2 = Services.contacts.listGroups();
    _invitesCountFuture = Services.contacts.friendInvitesCount();

    final rs = await Future.wait([f1, f2]);
    if (!mounted) return;
    setState(() {
      _friendsAll = rs[0] as List<FriendDTO>;
      _groupsAll  = rs[1] as List<GroupDTO>;
      _loadingFriends = false;
      _loadingGroups  = false;
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ===== Helpers =====
  String _timeAgoShort(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays} ngày';
    if (d.inHours >= 1) return '${d.inHours} giờ';
    if (d.inMinutes >= 1) return '${d.inMinutes} phút';
    return 'vừa xong';
  }

  // lọc local
  List<FriendDTO> get _friendsFiltered {
    switch (_filter) {
      case FriendsFilter.all:     return _friendsAll;
      case FriendsFilter.newOnly: return _friendsAll.where((f) => f.isNew).toList();
      case FriendsFilter.online:  return _friendsAll.where((f) => f.online).toList();
    }
  }

  int get _countAll    => _friendsAll.length;
  int get _countNew    => _friendsAll.where((f) => f.isNew).length;
  int get _countOnline => _friendsAll.where((f) => f.online).length;

  // ====== UI pieces (KHÔNG CARD) ======

  // Lời mời kết bạn: ListTile trần
  Widget _inviteTile(int count) {
    if (count <= 0) return const SizedBox.shrink();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 16,
        child: Icon(Icons.person_add_alt, size: 16, color: Colors.white),
      ),
      title: const Text('Lời mời kết bạn', style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => Navigator.of(context)
          .pushNamed(AppRoutes.friendInvites)
          .then((_) => setState(() {})),
    );
  }

  // 3 filter pill nhỏ – căn trái
  Widget _friendFilters() {
    return Row(
      children: [
        Expanded(
          child: _FilterPill(
            label: 'Tất cả',
            count: _countAll,
            selected: _filter == FriendsFilter.all,
            onTap: () => setState(() => _filter = FriendsFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilterPill(
            label: 'Bạn mới',
            count: _countNew,
            selected: _filter == FriendsFilter.newOnly,
            onTap: () => setState(() => _filter = FriendsFilter.newOnly),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FilterPill(
            label: 'Trực tuyến',
            count: _countOnline,
            selected: _filter == FriendsFilter.online,
            onTap: () => setState(() => _filter = FriendsFilter.online),
          ),
        ),
      ],
    );
  }

  // item bạn bè gọn
  Widget _friendRow(FriendDTO f) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.profile,
        arguments: {'userId': f.id},
      ),
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: (f.avatarUrl != null && f.avatarUrl!.isNotEmpty)
            ? NetworkImage(f.avatarUrl!)
            : null,
        child: (f.avatarUrl == null || f.avatarUrl!.isEmpty)
            ? Text(f.displayName.characters.first.toUpperCase())
            : null,
      ),
      title: Text(
        f.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconSmall(Icons.phone_outlined, 'Gọi thoại'),
          const SizedBox(width: 4),
          _iconSmall(Icons.videocam_outlined, 'Gọi video'),
        ],
      ),
    );
  }

  Widget _iconSmall(IconData icon, String tooltip) {
    return IconButton(
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: () {},
      tooltip: tooltip,
      icon: Icon(icon),
    );
  }

  // header nhóm + nút sắp xếp ≡ (không card)
  Widget _groupsHeader({
    required int count,
    required GroupSort current,
    required ValueChanged<GroupSort> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Nhóm đang tham gia ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  TextSpan(
                    text: '($count)',
                    style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _SortButton(current: current, onSelected: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Column(
          children: [
            // Tab selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tab,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(vertical: 8),
                tabs: const [Text('Bạn bè'), Text('Nhóm')],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // ================= TAB BẠN BÈ (NO CARD) =================
                  if (_loadingFriends)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        // Lời mời kết bạn
                        FutureBuilder<int>(
                          future: _invitesCountFuture,
                          builder: (_, s) => _inviteTile(s.data ?? 0),
                        ),
                        const Divider(height: 1),

                        // Filter hàng nhỏ
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                          child: _friendFilters(),
                        ),
                        const SizedBox(height: 4),
                        const Divider(height: 1),

                        // Nhóm theo ký tự đầu
                        Builder(
                          builder: (_) {
                            final friends = _friendsFiltered;
                            if (friends.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(14),
                                child: Center(child: Text('Không có bạn bè')),
                              );
                            }
                            final grouped = <String, List<FriendDTO>>{};
                            for (final f in friends) {
                              final k = f.displayName.isEmpty
                                  ? '#'
                                  : f.displayName[0].toUpperCase();
                              (grouped[k] ??= []).add(f);
                            }
                            final keys = grouped.keys.toList()..sort();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: keys.length,
                              itemBuilder: (_, i) {
                                final k = keys[i];
                                final list = grouped[k]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    QSectionHeader(k),
                                    ...list.map(_friendRow),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),

                  // ================= TAB NHÓM (NO CARD) =================
                  if (_loadingGroups)
                    const Center(child: CircularProgressIndicator())
                  else
                    ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        // Tạo nhóm mới
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.group_add)),
                          title: const Text('Tạo nhóm mới'),
                          onTap: () async {
                            final res = await Navigator.of(context).pushNamed(AppRoutes.createGroup);
                            // res là map mock từ CreateGroupPage khi bấm "TẠO NHÓM"
                            if (res is Map && res['conversationId'] != null) {
                              // TODO: sau này gọi ChatScreen thật; tạm thời chỉ show snack
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã tạo nhóm: ${res['title']}')),
                              );

                              // Nếu đã có ChatScreen và route chat:
                              // Navigator.of(context).pushNamed(AppRoutes.chat, arguments: {
                              //   'conversationId': res['conversationId'],
                              //   'title': res['title'],
                              // });
                            }
                          },
                        ),
                        const Divider(height: 1),

                        // Header + sort
                        _groupsHeader(
                          count: _groupsAll.length,
                          current: _groupSort,
                          onChanged: (v) => setState(() => _groupSort = v),
                        ),
                        const Divider(height: 1),

                        // Danh sách nhóm
                        Builder(builder: (_) {
                          final data = List<GroupDTO>.from(_groupsAll);
                          switch (_groupSort) {
                            case GroupSort.activity:
                              data.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
                              break;
                            case GroupSort.name:
                              data.sort((a, b) => a.title.compareTo(b.title));
                              break;
                            case GroupSort.managed:
                              data.sort((a, b) {
                                if (a.isManaged == b.isManaged) {
                                  return a.title.compareTo(b.title);
                                }
                                return a.isManaged ? -1 : 1;
                              });
                              break;
                          }

                          if (data.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(14),
                              child: Center(child: Text('Bạn chưa tham gia nhóm nào')),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final g = data[i];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRoutes.chat,
                                  arguments: {
                                    'conversationId': g.id,
                                    'title': g.title,
                                  },
                                ),
                                leading: CircleAvatar(
                                  radius: 18,
                                  child: Text(g.title.characters.first.toUpperCase()),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        g.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (g.muted)
                                      const Icon(Icons.notifications_off, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      _timeAgoShort(g.lastActivityAt),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    g.lastMessagePreview ?? '${g.memberCount} thành viên',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== Filter pill (nhỏ, căn trái, cao 30) =====
class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg  = selected ? cs.primaryContainer.withOpacity(.55) : Colors.white;
    final bd  = selected ? Colors.transparent : const Color(0xFFE5E7EB);
    final txt = selected ? cs.onPrimaryContainer : const Color(0xFF374151);
    final txtMuted = selected ? cs.onPrimaryContainer : const Color(0xFF6B7280);

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: bd)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: txt,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: txtMuted,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===== Nút sắp xếp ≡ cho tab Nhóm =====
class _SortButton extends StatelessWidget {
  final GroupSort current;
  final ValueChanged<GroupSort> onSelected;
  const _SortButton({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GroupSort>(
      tooltip: 'Sắp xếp',
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(value: GroupSort.activity, child: Text('Hoạt động cuối')),
        PopupMenuItem(value: GroupSort.name,     child: Text('Tên nhóm')),
        PopupMenuItem(value: GroupSort.managed,  child: Text('Nhóm quản lý')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dehaze, size: 18, color: Color(0xFF111827)),
            const SizedBox(width: 6),
            Text(
              'Sắp xếp',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
