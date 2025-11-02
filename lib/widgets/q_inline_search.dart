import 'package:flutter/material.dart';

/// Ô tìm kiếm nhỏ gọn đặt trong trang con (khác với search ở Header).
/// - Tự hiển thị nút Clear khi có text
/// - Có thể nhét vào Card/Section, dialog chọn thành viên, v.v.
/// - Không phụ thuộc vào service/backend
class QInlineSearch extends StatefulWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool dense;   // true = chiều cao thấp gọn
  final bool filled;  // true = nền xám nhạt

  const QInlineSearch({
    super.key,
    this.hint = 'Tìm kiếm',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.dense = true,
    this.filled = true,
  });

  @override
  State<QInlineSearch> createState() => _QInlineSearchState();
}

class _QInlineSearchState extends State<QInlineSearch> {
  late final TextEditingController _c;
  bool _ownController = false;

  @override
  void initState() {
    super.initState();
    _ownController = widget.controller == null;
    _c = widget.controller ?? TextEditingController();
    _c.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {}); // để hiện/ẩn nút clear

  @override
  void dispose() {
    _c.removeListener(_onTextChanged);
    if (_ownController) _c.dispose();
    super.dispose();
  }

  void _clear() {
    _c.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    );

    return TextField(
      controller: _c,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        isDense: widget.dense,
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: (_c.text.isNotEmpty)
            ? IconButton(
          tooltip: 'Xoá',
          icon: const Icon(Icons.close_rounded),
          onPressed: _clear,
        )
            : null,
        filled: widget.filled,
        fillColor: widget.filled ? const Color(0xFFF5F7FA) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 1.2),
        ),
      ),
    );
  }
}
