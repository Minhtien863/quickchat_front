// lib/views/chat/chat_search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';

class ChatSearchPage extends StatefulWidget {
  final String conversationId;
  final String title;
  const ChatSearchPage({
    super.key,
    required this.conversationId,
    required this.title,
  });

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  String _q = '';
  late List<_DemoMsg> _all;
  late List<_DemoMsg> _filtered;

  @override
  void initState() {
    super.initState();
    _all = _demo;        // mock data
    _filtered = const [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
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
    _debounce = Timer(const Duration(milliseconds: 240), () {
      final q = v.trim().toLowerCase();
      setState(() {
        _q = q;
        _filtered = q.isEmpty
            ? const []
            : _all.where((m) => m.text.toLowerCase().contains(q)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header gradient + ô tìm kiếm bo tròn
          SliverAppBar(
            pinned: true,
            expandedHeight: 112,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.black54),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: _c,
                                    focusNode: _focus,
                                    onChanged: _onChanged,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      hintText: 'Tìm trong “${widget.title}”',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (_c.text.isNotEmpty)
                                  IconButton(
                                    splashRadius: 18,
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      _c.clear();
                                      _onChanged('');
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_q.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  'Nhập từ khóa để tìm tin nhắn',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else if (_filtered.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text('Không tìm thấy kết quả phù hợp'),
              ),
            )
          else
            SliverList.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = _filtered[i];
                return ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: CircleAvatar(
                    radius: 18,
                    child: Text(m.sender[0].toUpperCase()),
                  ),
                  title: Text(
                    m.sender,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    m.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    m.time, // ví dụ “16:08” / “Hôm qua”
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () {
                    // TODO: sau này: scroll tới messageId trong ChatScreen
                    Navigator.pop(context);
                  },
                );
              },
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/* ------- mock data để dựng UI ------- */
class _DemoMsg {
  final String sender;
  final String text;
  final String time;
  const _DemoMsg(this.sender, this.text, this.time);
}

const _demo = <_DemoMsg>[
  _DemoMsg('hai.ng', 'Chiều họp nhé', '1 phút'),
  _DemoMsg('minh.tien', 'Ok 15:00 gặp ở lab', '3 phút'),
  _DemoMsg('linh.ng', 'Đã cập nhật file CV', 'Hôm qua'),
  _DemoMsg('kid.group', 'Hôm nay sinh nhật Nguyễn Xuân Phong', '2 giờ'),
];
