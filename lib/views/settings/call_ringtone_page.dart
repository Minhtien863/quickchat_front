import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';

class CallRingtonePage extends StatefulWidget {
  const CallRingtonePage({super.key});

  @override
  State<CallRingtonePage> createState() => _CallRingtonePageState();
}

class _CallRingtonePageState extends State<CallRingtonePage> {
  // build state
  final List<String> _tones = [
    'Mặc định QuickChat',
    'Nhẹ nhàng',
    'Năng động',
    'Cổ điển',
    'Im lặng',
  ];
  String _selected = 'Mặc định QuickChat';

  // build main
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Nhạc chuông cuộc gọi',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Chọn âm thanh làm nhạc chuông cho cuộc gọi đến. '
                  'Sau này sẽ nối với danh sách âm thanh thực tế.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _tones.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final name = _tones[i];
                final selected = _selected == name;
                return RadioListTile<String>(
                  value: name,
                  groupValue: _selected,
                  activeColor: cs.primary,
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selected = v);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã chọn "$v" làm nhạc chuông (mock)'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
