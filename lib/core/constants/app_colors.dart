import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0D0D0D);
  static const Color card = Color(0xFF181818);
  static const Color cardElevated = Color(0xFF222222);
  static const Color accent = Color(0xFFFF8A00);
  static const Color accentSecondary = Color(0xFFFFC15E);
  static const Color green = Color(0xFF36D399);
  static const Color red = Color(0xFFFF5D73);
  static const Color blue = Color(0xFF5DA9FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFA3A3A3);
  static const Color greyDark = Color(0xFF6B6B6B);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFF141414);
  static const Color border = Color(0xFF2A2A2A);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentSecondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E1E), Color(0xFF141414)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1208), background],
  );
}
