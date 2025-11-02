import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppSection { messages, contacts, notifications, profile }

class QAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final double height;
  const QAppHeader._(this.child, this.height, {super.key});

  // ========= HOME (thu gọn: nút Search giả + actions theo tab) =========
  factory QAppHeader.home({
    required AppSection section,
    VoidCallback? onTapSearch,
    VoidCallback? onAddFriend,
    VoidCallback? onNewChat,
    VoidCallback? onSettings,
  }) {
    // actions theo tab
    List<Widget> actions;
    switch (section) {
      case AppSection.messages:
        actions = [ _IconPlain(icon: Icons.add, onPressed: onNewChat) ];
        break;
      case AppSection.contacts:
        actions = [ _IconPlain(icon: Icons.person_add_alt, onPressed: onAddFriend) ];
        break;
      case AppSection.notifications:
      case AppSection.profile:
        actions = [ _IconPlain(icon: Icons.settings_outlined, onPressed: onSettings) ];
        break;
    }

    final shell = _GradientShell(
      systemUi: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              // Nút search giả: icon + text
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onTapSearch,
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.white, size: 26),
                      SizedBox(width: 10),
                      Text(
                        'Tìm kiếm',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ..._spaced(actions),
            ],
          ),
        ),
      ),
    );

    return QAppHeader._(shell, 64);
  }

  // ========= SEARCH (mở rộng với TextField) =========
  factory QAppHeader.search({
    required VoidCallback onBack,
    required ValueChanged<String> onChanged,
    String hint = 'Tìm kiếm',
    TextEditingController? controller,
    FocusNode? focusNode,
  }) {
    final shell = _GradientShell(
      systemUi: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
                splashRadius: 22,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: hint,
                      hintStyle: const TextStyle(color: Colors.black38),
                      prefixIcon: const Icon(Icons.search, color: Colors.black45),
                      prefixIconConstraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );

    return QAppHeader._(shell, kToolbarHeight + 10);
  }

  // ========= CHAT HEADER (giữ icon, nền gradient) =========
  factory QAppHeader.chat({
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    VoidCallback? onCall,
    VoidCallback? onVideo,
    VoidCallback? onMore,
    String? avatarUrl,               // <— thêm: để show avatar
    String? avatarFallback,          // <— ký tự fallback
  }) {
    const double kRowH = kToolbarHeight;      // 56
    const double kIconPad = 2;
    const double kActionSize = 40;            // nút action đồng bộ
    const double kAvatarRadius = 16;          // 32px

    Widget _action(IconData ico, VoidCallback? onTap) => SizedBox(
      width: kActionSize,
      height: kActionSize,
      child: IconButton(
        padding: const EdgeInsets.all(kIconPad),
        icon: Icon(ico, color: Colors.white),
        splashRadius: 22,
        onPressed: onTap,
      ),
    );

    final shell = _GradientShell(
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kRowH,                       // tránh tràn chiều cao
          child: Row(
            children: [
              // back
              SizedBox(
                width: kActionSize,
                height: kActionSize,
                child: IconButton(
                  padding: const EdgeInsets.all(kIconPad),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  splashRadius: 22,
                  onPressed: onBack,
                ),
              ),
              // avatar
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: kAvatarRadius,
                  backgroundImage:
                  (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  backgroundColor: const Color(0x22FFFFFF),
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                    (avatarFallback ?? title).characters.first.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  )
                      : null,
                ),
              ),
              // title + subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
              // actions
              _action(Icons.phone, onCall),
              _action(Icons.videocam, onVideo),
              _action(Icons.more_vert, onMore),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );

    return QAppHeader._(shell, kRowH);
  }

  // ========= PLAIN/TITLE-ONLY (nền gradient đồng bộ) =========
  /// Dùng cho các trang không có ô tìm kiếm (Thêm bạn, Lời mời kết bạn, v.v.)
  /// - Mặc định: nền gradient như Home/Search/Chat (đồng bộ brand)
  /// - Nếu muốn nền trắng thì dùng [QAppHeader.plainSurface].
  factory QAppHeader.plain({
    Key? key,
    required String title,
    VoidCallback? onBack,
    bool centerTitle = false,
  }) {
    final body = _GradientShell(
      systemUi: SystemUiOverlayStyle.light,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                  splashRadius: 22,
                ),
              Expanded(
                child: Align(
                  alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return QAppHeader._(body, kToolbarHeight + 8, key: key);
  }

  // ========= PLAIN SURFACE (nền trắng khi cần) =========
  factory QAppHeader.plainSurface({
    Key? key,
    required String title,
    VoidCallback? onBack,
    bool centerTitle = false,
  }) {
    final body = SafeArea(
      bottom: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
            Expanded(
              child: Align(
                alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return QAppHeader._(body, kToolbarHeight + 8, key: key);
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) => child;
}

// =========== Helpers ===========

class _GradientShell extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final SystemUiOverlayStyle? systemUi;
  const _GradientShell({
    required this.child,
    this.colors,
    this.systemUi,
  });

  @override
  Widget build(BuildContext context) {
    // áp dụng màu biểu tượng status bar sáng
    if (systemUi != null) {
      SystemChrome.setSystemUIOverlayStyle(systemUi!);
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              const [Color(0xFF2DAAE1), Color(0xFF0A84FF)], // brand gradient
        ),
      ),
      child: child,
    );
  }
}

class _IconPlain extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _IconPlain({required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      splashRadius: 22,
      onPressed: onPressed,
    );
  }
}

List<Widget> _spaced(List<Widget> xs) {
  final out = <Widget>[];
  for (var i = 0; i < xs.length; i++) {
    if (i != 0) out.add(const SizedBox(width: 12));
    out.add(xs[i]);
  }
  return out;
}
