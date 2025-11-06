// lib/views/settings/edit_email_page.dart
import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';
import '../../widgets/tokens.dart';

class EditEmailPage extends StatefulWidget {
  final String? currentEmail;

  const EditEmailPage({super.key, this.currentEmail});

  @override
  State<EditEmailPage> createState() => _EditEmailPageState();
}

class _EditEmailPageState extends State<EditEmailPage> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.currentEmail ?? '');
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
      const SnackBar(content: Text('Đã cập nhật email (mock)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Email',
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
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập email',
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
