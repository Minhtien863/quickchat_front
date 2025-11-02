import 'package:flutter/material.dart';

class QHintChips extends StatelessWidget {
  final List<QHint> hints;
  const QHintChips({super.key, required this.hints});

  factory QHintChips.defaults() => const QHintChips(
    hints: [
      QHint(Icons.email_outlined, 'Email'),
      QHint(Icons.phone_outlined, 'Phone'),
      QHint(Icons.alternate_email, '@handle'),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: hints
            .expand((h) => [
          _Chip(icon: h.icon, text: h.text),
          const SizedBox(width: 8),
        ])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class QHint {
  final IconData icon;
  final String text;
  const QHint(this.icon, this.text);
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Chip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
