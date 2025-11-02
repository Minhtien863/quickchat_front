import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinSheet extends StatefulWidget {
  final String title;
  final bool confirmMode; // true: tạo PIN (nhập + xác nhận)

  const PinSheet({
    super.key,
    required this.title,
    this.confirmMode = false,
  });

  @override
  State<PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<PinSheet> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  bool get _ok1 => _c1.text.length == 6;
  bool get _ok2 => _c2.text.length == 6;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      )),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _PinField(controller: _c1, label: widget.confirmMode ? 'Nhập PIN' : 'PIN 6 số'),
            if (widget.confirmMode) ...[
              const SizedBox(height: 8),
              _PinField(controller: _c2, label: 'Nhập lại PIN'),
            ],
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!_ok1 || (widget.confirmMode && !_ok2)) return;
                  if (widget.confirmMode && _c1.text != _c2.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN xác nhận không khớp')),
                    );
                    return;
                  }
                  Navigator.pop(context, _c1.text);
                },
                child: Text(widget.confirmMode ? 'Lưu PIN' : 'Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 6,
      obscureText: true,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: '••••••',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
