import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';

class FontSizePage extends StatefulWidget {
  const FontSizePage({super.key});

  @override
  State<FontSizePage> createState() => _FontSizePageState();
}

class _FontSizePageState extends State<FontSizePage> {
  // trạng thái mock
  bool _useSystem = true;
  double _slider = 0; // 0..4

  // hệ số scale chữ
  double get _scale {
    if (_useSystem) return 1.0;
    return 0.85 + _slider * 0.15; // 0.85 → 1.45
  }

  // preview ô chat
  Widget _chatPreview() {
    final cs = Theme.of(context).colorScheme;
    final bubbleRadius = BorderRadius.circular(18);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F4FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFF60A5FA),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: bubbleRadius,
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  'Xin chào',
                  style: TextStyle(
                    fontSize: 15 * _scale,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.9),
                    borderRadius: bubbleRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Chào bạn, lâu không gặp',
                    style: TextStyle(
                      fontSize: 15 * _scale,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '11:45',
                  style: TextStyle(
                    fontSize: 11 * _scale,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // preview ô tin nhắn trong danh sách
  Widget _listPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF93C5FD),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'An An',
                  style: TextStyle(
                    fontSize: 15 * _scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Xin chào',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13 * _scale,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '11:45',
            style: TextStyle(
              fontSize: 11 * _scale,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // thanh slider chọn cỡ chữ
  Widget _fontSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kéo để thay đổi cỡ chữ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  color: _useSystem
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _slider,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: _useSystem
                      ? null
                      : (v) => setState(() => _slider = v),
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 20,
                  color: _useSystem
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Thay đổi cỡ chữ',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          _chatPreview(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'Cỡ chữ trong trò chuyện',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _listPreview(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              'Cỡ chữ trên trang tin nhắn',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Dùng cỡ chữ thiết bị',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            value: _useSystem,
            onChanged: (v) {
              setState(() {
                _useSystem = v;
                if (v) _slider = 0;
              });
            },
            subtitle: Text(
              'Nếu bật, QuickChat sẽ dùng cùng cỡ chữ với hệ thống.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
          _fontSlider(),
        ],
      ),
    );
  }
}
