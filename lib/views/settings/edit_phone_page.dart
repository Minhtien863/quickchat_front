// lib/views/settings/edit_phone_page.dart
import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';

class EditPhonePage extends StatefulWidget {
  final String? currentPhone;

  const EditPhonePage({super.key, this.currentPhone});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.currentPhone ?? '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // lưu mock
  Future<void> _save() async {
    Navigator.pop(context, _c.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật số điện thoại (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Số điện thoại',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: TextField(
                controller: _c,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập số điện thoại',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('LƯU'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
