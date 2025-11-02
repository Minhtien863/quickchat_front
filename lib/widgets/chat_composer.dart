import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatComposer extends StatefulWidget {
  final ValueChanged<String> onSendText;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onToggleEmoji;
  final VoidCallback onSendLike;
  final bool isSending;

  final Future<bool> Function(String text)? onLongPressSend;

  const ChatComposer({
    super.key,
    required this.onSendText,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onToggleEmoji,
    required this.onSendLike,
    this.isSending = false,
    this.onLongPressSend,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _c = TextEditingController();
  final _focus = FocusNode();
  bool _foldLeft = false;

  bool get _hasText => _c.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _foldLeft = _focus.hasFocus); // thu gọn khi focus
    });
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = _c.text.trim();
    if (t.isEmpty || widget.isSending) return;
    widget.onSendText(t);
    _c.clear();
  }

  @override
  Widget build(BuildContext context) {
    const double h = 44;          // chiều cao ô nhập
    const double iconBox = 36;    // kích thước ô icon trái
    const double actionSize = 44; // kích thước nút gửi/like

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Row(
          children: [
            // ===== CỤM TRÁI: camera / gallery hoặc nút ">"
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: SizeTransition(sizeFactor: a, axis: Axis.horizontal, child: c),
              ),
              child: _foldLeft
                  ? SizedBox(
                key: const ValueKey('folded'),
                width: iconBox,
                height: h,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    _focus.unfocus();
                    setState(() => _foldLeft = false);
                  },
                  tooltip: 'Mở nhanh công cụ',
                ),
              )
                  : Row(
                key: const ValueKey('icons'),
                children: [
                  _squareIcon(
                    size: iconBox,
                    icon: Icons.photo_camera,
                    onTap: widget.onPickCamera,
                  ),
                  const SizedBox(width: 6),
                  _squareIcon(
                    size: iconBox,
                    icon: Icons.image_outlined,
                    onTap: widget.onPickGallery,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ===== Ô NHẬP
            Expanded(
              child: SizedBox(
                height: h,
                child: TextField(
                  controller: _c,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn…',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    // emoji trong ô nhập (bên phải)
                    suffixIcon: IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.emoji_emotions_outlined),
                      onPressed: widget.onToggleEmoji,
                      tooltip: 'Biểu tượng cảm xúc',
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ===== NÚT LIKE / GỬI (kèm long-press để hẹn giờ)
            SizedBox(
              width: actionSize,
              height: actionSize,
              child: GestureDetector(
                onLongPress: () async {
                  if (widget.onLongPressSend != null) {
                    final ok = await widget.onLongPressSend!(_c.text);
                    if (ok == true){
                      _c.clear();
                      _focus.unfocus();
                      setState(() {});
                    }
                  }
                },
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  onPressed: widget.isSending
                      ? null
                      : _hasText ? _submit : widget.onSendLike,
                  child: widget.isSending
                      ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Icon(_hasText ? Icons.send : Icons.thumb_up_alt_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareIcon({
    required double size,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(icon, size: 20, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

/* ====== (Không bắt buộc) — Các tiện ích bạn có thể dùng lại sau ====== */

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onEmojiTap;
  final String hint;

  const _InputBox({
    required this.controller,
    required this.focusNode,
    required this.onEmojiTap,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: cs.surface,
            contentPadding: const EdgeInsets.fromLTRB(12, 10, 40, 10), // chừa chỗ emoji
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        IconButton(
          onPressed: onEmojiTap,
          icon: const Icon(Icons.emoji_emotions_outlined),
          splashRadius: 18,
          color: cs.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool sendMode;
  final String emoji;
  final Future<void> Function() onTap;
  final VoidCallback? onLongPress;

  const _ActionButton({
    required this.sendMode,
    required this.emoji,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onTap(),
        onLongPress: onLongPress,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: sendMode
                ? const Icon(Icons.send, size: 18, color: Colors.white)
                : Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}

class _EmojiPickItem extends StatelessWidget {
  final String emoji;
  const _EmojiPickItem(this.emoji);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pop(context, emoji),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.35),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}
