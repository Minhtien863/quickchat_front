import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../services/contacts_service.dart';
import '../../../services/service_registry.dart';
import '../../../widgets/q_search_field.dart';
import '../../../widgets/q_section_header.dart';
import '../../../widgets/q_tiles.dart';
import '../../../widgets/tokens.dart';

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ===== State =====
  String _q = '';
  FriendsFilter _filter = FriendsFilter.all;
  GroupSort _groupSort = GroupSort.activity;

  late Future<List<FriendDTO>> _friendsFuture;
  late Future<List<GroupDTO>> _groupsFuture;

  late Future<int> _invitesCountFuture;
  late Future<int> _countAllFut;
  late Future<int> _countOnlineFut;
  late Future<int> _countNewFut;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // Đổi tab thì reload để đảm bảo badge/filters hiển thị đúng
    _tab.addListener(() {
      if (mounted) setState(_reload);
    });
    _reload();
  }

  void _reload() {
    _friendsFuture = Services.contacts.listFriends(q: _q, filter: _filter);
    _groupsFuture = Services.contacts.listGroups(q: _q);

    _invitesCountFuture = Services.contacts.friendInvitesCount();
    _countAllFut = Services.contacts.friendsCount();
    _countOnlineFut = Services.contacts.onlineFriendsCount();
    _countNewFut = Services.contacts.newFriendsCount();
  }

  void _onSearch(String v) {
    setState(() {
      _q = v;
      _reload();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // ===== UI helpers =====
  Widget _inviteCard(int count) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_add_alt)),
        title: const Text('Lời mời kết bạn'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.of(context)
            .pushNamed(AppRoutes.friendInvites)
            .then((_) => setState(_reload)),
      ),
    );
  }

  String _timeAgoShort(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays} ngày';
    if (d.inHours >= 1) return '${d.inHours} giờ';
    if (d.inMinutes >= 1) return '${d.inMinutes} phút';
    return 'vừa xong';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Column(
          children: [
            // Search
            QSearchField(hint: 'Tìm bạn hoặc nhóm', onChanged: _onSearch),
            Gaps.sm,

            // Tab selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TabBar(
                controller: _tab,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(vertical: 10),
                tabs: const [Text('Bạn bè'), Text('Nhóm')],
              ),
            ),
            Gaps.md,

            // ===== Chỉ hiển thị ở tab Bạn bè =====
            if (_tab.index == 0) ...[
              // Badge "Lời mời kết bạn"
              FutureBuilder<int>(
                future: _invitesCountFuture,
                builder: (_, snap) {
                  final count = snap.data ?? 0;
                  if (count <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _inviteCard(count),
                  );
                },
              ),
              // Filter segmented nhỏ + canh trái
              FutureBuilder3<int, int, int>(
                f1: _countAllFut,
                f2: _countNewFut,
                f3: _countOnlineFut,
                builder: (all, neu, onl) {
                  final a = all ?? 0, n = neu ?? 0, o = onl ?? 0;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: SegmentedButton<FriendsFilter>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          visualDensity: VisualDensity.compact,
                          textStyle: MaterialStatePropertyAll(
                            Theme.of(context).textTheme.labelSmall,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        segments: [
                          ButtonSegment(
                            value: FriendsFilter.all,
                            label: Text('Tất cả ($a)'),
                          ),
                          ButtonSegment(
                            value: FriendsFilter.newOnly,
                            label: Text('Bạn mới ($n)'),
                          ),
                          ButtonSegment(
                            value: FriendsFilter.online,
                            label: Text('Trực tuyến ($o)'),
                          ),
                        ],
                        selected: <FriendsFilter>{_filter},
                        onSelectionChanged: (s) =>
                            setState(() => {_filter = s.first, _reload()}),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],

            // ===== Content =====
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // ---------- Tab Bạn bè ----------
                  FutureBuilder<List<FriendDTO>>(
                    future: _friendsFuture,
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snap.data ?? [];
                      if (data.isEmpty) {
                        return const Center(child: Text('Không có bạn bè'));
                      }

                      // Group theo ký tự đầu
                      final grouped = <String, List<FriendDTO>>{};
                      for (final f in data) {
                        final k = f.displayName.isEmpty
                            ? '#'
                            : f.displayName[0].toUpperCase();
                        (grouped[k] ??= []).add(f);
                      }
                      final keys = grouped.keys.toList()..sort();

                      return ListView.builder(
                        itemCount: keys.length,
                        itemBuilder: (_, i) {
                          final k = keys[i];
                          final list = grouped[k]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QSectionHeader(k),
                              ...list.map(
                                    (f) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    child: FriendTile(
                                      f: f,
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(
                                        AppRoutes.profile,
                                        arguments: {'userId': f.id},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Gaps.xs,
                            ],
                          );
                        },
                      );
                    },
                  ),

                  // ---------- Tab Nhóm ----------
                  FutureBuilder<List<GroupDTO>>(
                    future: _groupsFuture,
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var data = List<GroupDTO>.from(snap.data ?? []);
                      if (data.isEmpty) {
                        return const Center(
                            child: Text('Bạn chưa tham gia nhóm nào'));
                      }

                      // Sort theo lựa chọn
                      switch (_groupSort) {
                        case GroupSort.activity:
                          data.sort((a, b) =>
                              b.lastActivityAt.compareTo(a.lastActivityAt));
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

                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: data.length + 2, // + "Tạo nhóm" + header
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          // 0: "Tạo nhóm mới"
                          if (i == 0) {
                            return Card(
                              child: ListTile(
                                leading:
                                const CircleAvatar(child: Icon(Icons.group_add)),
                                title: const Text('Tạo nhóm mới'),
                                onTap: () {},
                              ),
                            );
                          }

                          // 1: Header + Sắp xếp
                          if (i == 1) {
                            return Padding(
                              padding:
                              const EdgeInsets.fromLTRB(4, 8, 4, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Nhóm đang tham gia (${data.length})',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  PopupMenuButton<GroupSort>(
                                    tooltip: 'Sắp xếp',
                                    onSelected: (v) =>
                                        setState(() => _groupSort = v),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: GroupSort.activity,
                                        child: Text('Hoạt động cuối'),
                                      ),
                                      PopupMenuItem(
                                        value: GroupSort.name,
                                        child: Text('Tên nhóm'),
                                      ),
                                      PopupMenuItem(
                                        value: GroupSort.managed,
                                        child: Text('Nhóm quản lý'),
                                      ),
                                    ],
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.sort),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sắp xếp',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Items nhóm
                          final g = data[i - 2];
                          return Card(
                            child: ListTile(
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.chat,
                                arguments: {
                                  'conversationId': g.id,
                                  'title': g.title,
                                },
                              ),
                              leading: CircleAvatar(
                                child: Text(
                                  g.title.characters.first.toUpperCase(),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      g.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (g.muted)
                                    const Icon(Icons.notifications_off, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    _timeAgoShort(g.lastActivityAt),
                                    style:
                                    Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  g.lastMessagePreview ??
                                      '${g.memberCount} thành viên',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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

/// Tiện ích gộp 3 Future để lấy số liệu chips
class FutureBuilder3<A, B, C> extends StatelessWidget {
  final Future<A> f1;
  final Future<B> f2;
  final Future<C> f3;
  final Widget Function(A?, B?, C?) builder;

  const FutureBuilder3({
    super.key,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<A>(
      future: f1,
      builder: (_, s1) {
        return FutureBuilder<B>(
          future: f2,
          builder: (_, s2) {
            return FutureBuilder<C>(
              future: f3,
              builder: (_, s3) {
                return builder(s1.data, s2.data, s3.data);
              },
            );
          },
        );
      },
    );
  }
}
