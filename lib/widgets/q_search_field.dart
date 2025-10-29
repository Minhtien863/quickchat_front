import 'package:flutter/material.dart';

class QSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const QSearchField({super.key, this.hint = 'Tìm kiếm', this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => onChanged?.call(''),
        ),
      ),
    );
  }
}
