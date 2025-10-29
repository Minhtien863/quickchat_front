import 'package:flutter/material.dart';

class QSectionHeader extends StatelessWidget {
  final String text;
  const QSectionHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
