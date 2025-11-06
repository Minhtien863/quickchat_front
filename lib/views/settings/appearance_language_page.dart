import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import 'font_size_page.dart';

class AppearanceLanguagePage extends StatefulWidget {
  const AppearanceLanguagePage({super.key});

  @override
  State<AppearanceLanguagePage> createState() => _AppearanceLanguagePageState();
}

class _AppearanceLanguagePageState extends State<AppearanceLanguagePage> {
  // trạng thái mock
  bool _darkMode = false;
  String _languageCode = 'vi'; // 'vi' hoặc 'en'

  // tiêu đề section
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  // container nhóm
  Widget _groupContainer(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  // tile chọn ngôn ngữ
  Widget _languageTile({
    required String code,
    required String label,
    required String flagText,
  }) {
    final selected = _languageCode == code;
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Text(
        flagText,
        style: const TextStyle(fontSize: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
      onTap: () {
        setState(() => _languageCode = code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chọn ngôn ngữ: $label (mock)')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Giao diện & Ngôn ngữ',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Giao diện'),
          _groupContainer([
            SwitchListTile(
              secondary: Icon(
                _darkMode ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
                color: _darkMode ? cs.primary : const Color(0xFF111827),
              ),
              title: const Text(
                'Chế độ tối',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _darkMode
                    ? 'Đang dùng giao diện nền tối'
                    : 'Đang dùng giao diện nền sáng',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? 'Bật chế độ tối (mock)' : 'Tắt chế độ tối (mock)',
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading:
              const Icon(Icons.text_fields_outlined, color: Colors.black87),
              title: const Text(
                'Đổi cỡ chữ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Điều chỉnh cỡ chữ trong ứng dụng',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FontSizePage(),
                  ),
                );
              },
            ),
          ]),

          _sectionTitle('Ngôn ngữ'),
          _groupContainer([
            _languageTile(
              code: 'vi',
              label: 'Tiếng Việt',
              flagText: '🇻🇳',
            ),
            const Divider(height: 1),
            _languageTile(
              code: 'en',
              label: 'English',
              flagText: '🇺🇸',
            ),
          ]),
        ],
      ),
    );
  }
}
