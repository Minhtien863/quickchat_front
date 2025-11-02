// lib/views/search/global_search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});
  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  // mock dữ liệu dựng UI
  final List<_Person> _recentContacts = const [
    _Person('Lâm Thiên', 'https://i.pravatar.cc/150?img=12'),
    _Person('Quice',     'https://i.pravatar.cc/150?img=5'),
    _Person('Trap boiii','https://i.pravatar.cc/150?img=48'),
    _Person('Báo Cáo...', 'https://i.pravatar.cc/150?img=22'),
  ];
  final List<String> _recentKeywords = ['lâm', 'qui', 'an', 'báo', 'bc'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _c.addListener(() => setState(() {})); // bật/tắt nút clear
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      // TODO: gọi search API toàn app bằng `v`
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // HEADER: gradient + back + ô search lớn + QR
          SliverAppBar(
            pinned: true,
            elevation: 0,
            toolbarHeight: 64,          // cố định chiều cao header
            collapsedHeight: 64,
            expandedHeight: 64,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF2DAAE1), Color(0xFF0A84FF)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  // padding hai bên giống nhau để không “lệch”
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // nút back (chiếm đúng 40x40 để cân với QR)
                      SizedBox(
                        width: 40, height: 40,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // ô search trắng – cao 44, bo 22, text/placeholder căn giữa theo chiều dọc
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44, maxHeight: 44),
                          child: ClipRRect(                          // CLIP children theo cùng radius
                            borderRadius: BorderRadius.circular(22),
                            child: Material(                         // chỉ 1 lớp trắng
                              color: Colors.white,
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(Icons.search, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _c,
                                      focusNode: _focus,
                                      onChanged: _onChanged,
                                      textInputAction: TextInputAction.search,
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration: const InputDecoration(
                                        hintText: 'Tìm kiếm',
                                        isDense: true,
                                        // TẮT nền và border của TextField để không tạo lớp trắng thứ 2
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(bottom: 2),
                                      ),
                                    ),
                                  ),
                                  if (_c.text.isNotEmpty)
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      splashRadius: 18,
                                      icon: const Icon(Icons.close, size: 18, color: Colors.black87),
                                      onPressed: () { _c.clear(); _onChanged(''); },
                                    ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== Liên hệ đã tìm =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Liên hệ đã tìm', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _recentContacts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final p = _recentContacts[i];
                  return Column(
                    children: [
                      CircleAvatar(radius: 28, backgroundImage: NetworkImage(p.avatarUrl)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 72,
                        child: Text(p.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ===== Từ khóa đã tìm =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Text('Từ khóa đã tìm', style: theme.textTheme.titleMedium),
            ),
          ),
          SliverList.separated(
            itemCount: _recentKeywords.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final k = _recentKeywords[i];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.search),
                title: Text(k),
                onTap: () {
                  _c
                    ..text = k
                    ..selection = TextSelection.fromPosition(TextPosition(offset: k.length));
                  _onChanged(k);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _recentKeywords.removeAt(i)),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _Person {
  final String name;
  final String avatarUrl;
  const _Person(this.name, this.avatarUrl);
}
