import 'package:flutter/material.dart';

class NeonColors {
  static const Color background = Color(0xFF0B0F16);
  static const Color backgroundAlt = Color(0xFF10151F);
  static const Color surface = Color(0xFF141B27);

  static const Color cyan = Color(0xFF3DF5FF);
  static const Color blue = Color(0xFF00D2FF);
  static const Color purple = Color(0xFF7A5CFF);

  static const Color text = Color(0xFFDCE3F1);
  static const Color mutedText = Color(0xFF707A8C);

  static const Color success = Color(0xFF1BC47D);
  static const Color warning = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFFF5252);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [cyan, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueCyanGradient = LinearGradient(
    colors: [blue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class NeonShadows {
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.45),
          blurRadius: 35,
          spreadRadius: 2,
          offset: const Offset(0, 18),
        ),
      ];
}

class NeonDecorations {
  static BoxDecoration glass({BorderRadiusGeometry? radius}) {
    return BoxDecoration(
      borderRadius: radius ?? BorderRadius.circular(24),
      border: Border.all(color: NeonColors.cyan.withOpacity(0.35)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.04),
          Colors.white.withOpacity(0.01),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: NeonColors.blue.withOpacity(0.2),
          blurRadius: 25,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration neonCard({BorderRadiusGeometry? radius}) {
    return BoxDecoration(
      borderRadius: radius ?? BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x6610151F),
          Color(0x330B0F16),
        ],
      ),
      border: Border.all(color: NeonColors.purple.withOpacity(0.35)),
      boxShadow: [
        BoxShadow(
          color: NeonColors.purple.withOpacity(0.25),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}
