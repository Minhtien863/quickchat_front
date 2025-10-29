import 'package:flutter/material.dart';

class Gaps {
  static const xxs = SizedBox(height: 4, width: 4);
  static const xs  = SizedBox(height: 8, width: 8);
  static const sm  = SizedBox(height: 12, width: 12);
  static const md  = SizedBox(height: 16, width: 16);
  static const lg  = SizedBox(height: 20, width: 20);
  static const xl  = SizedBox(height: 28, width: 28);
}

class Radii {
  static const sm  = 10.0;
  static const md  = 14.0;
  static const lg  = 18.0;
  static const xlg = 22.0;
}

BoxDecoration bubbleMe(BuildContext c) => BoxDecoration(
  color: Theme.of(c).colorScheme.primaryContainer,
  borderRadius: BorderRadius.circular(Radii.lg),
);

BoxDecoration bubbleOther() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(Radii.lg),
  border: Border.all(color: const Color(0xFFE5E7EB)),
);
