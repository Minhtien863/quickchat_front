import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final List<String> emojis;
  final ValueChanged<String> onPick;
  const ReactionBar({super.key, required this.emojis, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: emojis
            .map(
              (e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onPick(e),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
