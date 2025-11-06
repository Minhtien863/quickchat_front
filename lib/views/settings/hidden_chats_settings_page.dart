import 'package:flutter/material.dart';

import '../../widgets/q_app_header.dart';

class HiddenChatsSettingsPage extends StatelessWidget {
  const HiddenChatsSettingsPage({super.key});

  // mở flow đổi mã PIN toàn màn hình
  void _openChangePinFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const HiddenPinChangePage(),
      ),
    );
  }

  // xác nhận xóa mã PIN và dữ liệu ẩn
  Future<void> _confirmClearPin(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa mã PIN?'),
        content: const Text(
          'Xóa mã PIN sẽ xóa tất cả tin nhắn đã ẩn và lịch sử trò chuyện ẩn của bạn. '
              'Không ảnh hưởng đến người dùng khác.\n\nBạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      // TODO: xóa mã PIN và dữ liệu ẩn thực tế
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa mã PIN và dữ liệu ẩn (mock)'),
        ),
      );
    }
  }

  // section title
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

  // group container
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: QAppHeader.plain(
        title: 'Ẩn trò chuyện',
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Ẩn trò chuyện'),
          _groupContainer([
            ListTile(
              title: const Text(
                'Đổi mã PIN',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Đổi mã PIN 6 số dùng để mở các đoạn chat đã ẩn',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openChangePinFlow(context),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text(
                'Xóa mã PIN',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(
                'Xóa mã PIN và toàn bộ lịch sử các đoạn chat đã ẩn',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () => _confirmClearPin(context),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Khi ẩn một đoạn chat, bạn sẽ cần mã PIN để xem lại. '
                  'Việc xóa mã PIN sẽ đồng thời xóa mọi dữ liệu chat đã ẩn trên thiết bị của bạn.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class HiddenPinChangePage extends StatefulWidget {
  const HiddenPinChangePage({super.key});

  @override
  State<HiddenPinChangePage> createState() => _HiddenPinChangePageState();
}

class _HiddenPinChangePageState extends State<HiddenPinChangePage> {
  final _oldPinC = TextEditingController();
  final _newPinC = TextEditingController();
  final _confirmPinC = TextEditingController();

  int _step = 0;
  String? _error;

  @override
  void dispose() {
    _oldPinC.dispose();
    _newPinC.dispose();
    _confirmPinC.dispose();
    super.dispose();
  }

  // kiểm tra độ dài 6 số
  bool _isValidPin(String pin) => pin.length == 6 && int.tryParse(pin) != null;

  // xử lý bước tiếp theo
  void _nextStep() {
    setState(() => _error = null);

    if (_step == 0) {
      final pin = _oldPinC.text.trim();
      if (!_isValidPin(pin)) {
        setState(() => _error = 'Vui lòng nhập mã PIN 6 số hợp lệ');
        return;
      }
      // TODO: kiểm tra mã PIN cũ thực tế
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final pin = _newPinC.text.trim();
      if (!_isValidPin(pin)) {
        setState(() => _error = 'Mã PIN mới phải gồm 6 chữ số');
        return;
      }
      setState(() => _step = 2);
      return;
    }

    if (_step == 2) {
      final pin = _newPinC.text.trim();
      final confirm = _confirmPinC.text.trim();
      if (pin != confirm) {
        setState(() => _error = 'Mã PIN xác nhận không khớp');
        return;
      }
      // TODO: lưu mã PIN mới
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đổi mã PIN Ẩn trò chuyện (mock)')),
      );
      Navigator.pop(context);
    }
  }

  // build input theo step
  Widget _buildStepContent() {
    final cs = Theme.of(context).colorScheme;

    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã PIN hiện tại',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập mã PIN 6 số mà bạn đang dùng để mở các đoạn chat đã ẩn.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _oldPinC,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Mã PIN hiện tại',
            ),
          ),
        ],
      );
    }

    if (_step == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã PIN mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn mã PIN 6 số mới để bảo vệ các đoạn chat đã ẩn.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _newPinC,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Mã PIN mới',
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Xác nhận mã PIN mới',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập lại mã PIN mới để xác nhận.',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _confirmPinC,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Nhập lại mã PIN mới',
          ),
        ),
      ],
    );
  }

  // build nút tiếp tục
  Widget _buildPrimaryButton() {
    String label;
    if (_step == 0) {
      label = 'TIẾP TỤC';
    } else if (_step == 1) {
      label = 'TIẾP TỤC';
    } else {
      label = 'XÁC NHẬN';
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _nextStep,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Đổi mã PIN Ẩn trò chuyện',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepContent(),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _buildPrimaryButton(),
                    const SizedBox(height: 12),
                    Text(
                      'Hãy giữ mã PIN của bạn an toàn. QuickChat sẽ không thể hỗ trợ khôi phục nếu bạn quên mã PIN này (mock).',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
