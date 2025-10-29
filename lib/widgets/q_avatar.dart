import 'package:flutter/material.dart';

class QAvatar extends StatelessWidget {
  final String? label;       // fallback letter
  final String? imageUrl;
  final bool online;
  final double size;
  const QAvatar({super.key, this.label, this.imageUrl, this.online = false, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: (imageUrl == null)
          ? Text((label?.isNotEmpty == true ? label!.characters.first : '?').toUpperCase())
          : null,
    );
    return Stack(children: [
      avatar,
      Positioned(
        bottom: 2,
        right: 2,
        child: Container(
          width: size * 0.22,
          height: size * 0.22,
          decoration: BoxDecoration(
            color: online ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
          ),
        ),
      ),
    ]);
  }
}
