import 'package:flutter/material.dart';

/// =====================
/// COLOR SYSTEM (Light)
/// =====================
class AppColors {
  // Brand (giống header gradient bạn đang dùng)
  static const primary      = Color(0xFF0A84FF);
  static const primaryLite  = Color(0xFF2DAAE1);

  // Surface / Background
  static const canvas       = Color(0xFFF8F9FA); // nền app
  static const surface      = Colors.white;      // thẻ, card
  static const surfaceAlt   = Color(0xFFF3F4F6); // nền nhạt

  // Border / Divider
  static const border       = Color(0xFFE5E7EB);
  static const divider      = Color(0xFFEAECEF);

  // Text
  static const textPrimary  = Color(0xFF111827);
  static const textSecondary= Color(0xFF6B7280);
  static const textMute     = Color(0xFF9CA3AF);
  static const textOnPrimary= Colors.white;

  // States / Feedback (giữ tối giản)
  static const success      = Color(0xFF16A34A);
  static const danger       = Color(0xFFDC2626);
  static const warning      = Color(0xFFF59E0B);

  // Tonal icon bg (header home)
  static const tonal        = Colors.white; // trên nền gradient
}

/// =====================
/// SPACING & RADII
/// =====================
class Gaps {
  static const xxs = SizedBox(height: 4,  width: 4);
  static const xs  = SizedBox(height: 8,  width: 8);
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

/// =====================
/// ELEVATION / SHADOWS
/// =====================
class Shadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];
}

/// =====================
/// BORDERS & DECORATIONS
/// =====================
class Borders {
  static BorderRadius rx(double r) => BorderRadius.circular(r);

  static BoxDecoration card({
    double radius = Radii.md,
    Color color = AppColors.surface,
    List<BoxShadow>? shadows,
    Color borderColor = AppColors.border,
    bool withBorder = false,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: rx(radius),
      border: withBorder ? Border.all(color: borderColor) : null,
      boxShadow: shadows ?? Shadows.card,
    );
  }

  static InputBorder inputBorder([double r = Radii.md]) =>
      OutlineInputBorder(borderRadius: rx(r), borderSide: const BorderSide(color: AppColors.border));
}

/// =====================
/// GRADIENTS
/// =====================
class Gradients {
  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLite, AppColors.primary],
  );
}

/// =====================
/// DURATIONS
/// =====================
class Times {
  static const fast = Duration(milliseconds: 120);
  static const mid  = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
}

/// =====================
/// COMPONENT PRESETS
/// =====================

// Bong bóng chat (dùng cùng bảng màu)
BoxDecoration bubbleMe(BuildContext c) => BoxDecoration(
  color: Theme.of(c).colorScheme.primaryContainer, // theo theme để đồng bộ
  borderRadius: BorderRadius.circular(Radii.lg),
);

BoxDecoration bubbleOther() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(Radii.lg),
  border: const Border(
    top: BorderSide(color: AppColors.border),
    left: BorderSide(color: AppColors.border),
    right: BorderSide(color: AppColors.border),
    bottom: BorderSide(color: AppColors.border),
  ),
);

/// Card list item mặc định
BoxDecoration listCard() => Borders.card(radius: Radii.md);

/// Search pill/background trắng bo tròn
BoxDecoration searchPill() => Borders.card(
  radius: Radii.md,
  shadows: Shadows.card,
);

/// Segmented / Chip nền trắng
BoxDecoration chipWhite() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(Radii.sm),
  border: Border.all(color: AppColors.border),
  boxShadow: Shadows.soft,
);

/// Nút badge đếm (màu nhấn đồng bộ)
BoxDecoration countBadge() => BoxDecoration(
  color: AppColors.danger,
  borderRadius: BorderRadius.circular(24),
);
