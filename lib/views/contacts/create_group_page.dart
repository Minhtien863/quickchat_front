import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';
import '../../services/service_registry.dart';
import '../../services/contacts_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage>
    with SingleTickerProviderStateMixin {
  final _nameC = TextEditingController();
  final _searchC = TextEditingController();

  late final TabController _tab; // GẦN ĐÂY / DANH BẠ

  // dữ liệu
  List<FriendDTO> _friendsAll = [];
  List<FriendDTO> _friendsFiltered = [];
  final _selectedIds = <String>{};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadFriends();
    _searchC.addListener(_applyFilter);
  }

  Future<void> _loadFriends() async {
    setState(() => _loading = true);
    final friends = await Services.contacts.listFriends();
    if (!mounted) return;
    setState(() {
      _friendsAll = friends;
      _friendsFiltered = friends;
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _searchC.text.trim().toLowerCase();
    final all = _friendsAll;
    setState(() {
      if (q.isEmpty) {
        _friendsFiltered = all;
      } else {
        _friendsFiltered = all
            .where((f) => f.displayName.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  bool get _canContinue => _nameC.text.trim().isNotEmpty && _selectedIds.isNotEmpty;

  @override
  void dispose() {
    _tab.dispose();
    _nameC.dispose();
    _searchC.dispose();
    super.dispose();
  }

  // danh sách theo tab
  List<FriendDTO> _dataForTab() {
    final data = _friendsFiltered;
    if (_tab.index == 0) {
      // GẦN ĐÂY (demo: lấy 12 người đầu)
      return data.take(12).toList();
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Nhóm mới',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // hàng tiêu đề phụ + đếm chọn
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text('Đã chọn: ${_selectedIds.length}',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),

          // ô đặt tên nhóm (ảnh trái + textfield)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {}, // sau nối chọn ảnh
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: cs.primaryContainer.withOpacity(.35),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameC,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Đặt tên nhóm',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ô tìm kiếm
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchC,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tìm tên',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
              ),
            ),
          ),

          // tabs GẦN ĐÂY | DANH BẠ
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tab,
              labelPadding: const EdgeInsets.symmetric(vertical: 10),
              tabs: const [Text('GẦN ĐÂY'), Text('DANH BẠ')],
              onTap: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 1),

          // danh sách
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: _dataForTab().length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final f = _dataForTab()[i];
                final selected = _selectedIds.contains(f.id);
                return ListTile(
                  onTap: () => _toggleSelect(f.id),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: (f.avatarUrl != null &&
                        f.avatarUrl!.isNotEmpty)
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
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    // demo thời gian “N ngày trước” (nếu muốn, thay bằng lastInteraction)
                    '1 ngày trước',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleSelect(f.id),
                    shape: const CircleBorder(),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),

          // dải avatar đã chọn + nút tiến
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8 + 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedIds.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final id = _selectedIds.elementAt(i);
                          final f = _friendsAll.firstWhere((e) => e.id == id);
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: (f.avatarUrl != null &&
                                    f.avatarUrl!.isNotEmpty)
                                    ? NetworkImage(f.avatarUrl!)
                                    : null,
                                child: (f.avatarUrl == null || f.avatarUrl!.isEmpty)
                                    ? Text(f.displayName.characters.first.toUpperCase())
                                    : null,
                              ),
                              Positioned(
                                right: -6,
                                top: -6,
                                child: InkWell(
                                  onTap: () => _toggleSelect(id),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    onPressed: _canContinue
                        ? () {
                      // Chưa có backend: trả về mock data
                      Navigator.pop(context, {
                        'groupName': _nameC.text.trim(),
                        'memberIds': _selectedIds.toList(),
                      });
                    }
                        : null,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F8FA),
    );
  }
}
