import 'package:flutter/material.dart';

abstract final class AppColors {
  // ──── Brand — Royal Purple + Gold ────
  static const Color primary = Color(0xFF7B4FA6); // Royal Purple
  static const Color primaryLight = Color(0xFF9D6DC4); // Soft Lavender
  static const Color secondary = Color(0xFF3D7DD8); // Refined Blue
  static const Color gold = Color(0xFFC49A3C); // Luxury Gold

  // ──── Semantic ────
  static const Color success = Color(0xFF2A7A4F);
  static const Color successAlt = Color(0xFF38A169);
  static const Color warning = Color(0xFFD4891A);
  static const Color error = Color(0xFFC0392B);
  static const Color errorAlt = Color(0xFFE53E3E);

  // ──── Dark Theme — Deep Midnight ────
  static const Color background = Color(0xFF0C0B10);
  static const Color surface = Color(0xFF14121C);
  static const Color surfaceDeep = Color(0xFF1C192A);

  // ──── Light Theme — Luxury Ivory White ────
  static const Color backgroundLight = Color(0xFFF8F7FF); // Soft lavender white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDeepLight = Color(
    0xFFF0ECFB,
  ); // Light lavender tint

  // ──── Adaptive Helpers ────
  static Color bg(bool isDark) => isDark ? background : backgroundLight;
  static Color surf(bool isDark) => isDark ? surface : surfaceLight;
  static Color surfDeep(bool isDark) => isDark ? surfaceDeep : surfaceDeepLight;
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1C1823);
  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white70 : const Color(0xFF4A4265);
  static Color textHint(bool isDark) =>
      isDark ? Colors.white38 : const Color(0xFF9A94B8);
  static Color border(bool isDark) =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE4DFF5);

  // ──── History Screen Colors ────
  static const Color historyBg = Color(0xFF0D0D0F);
  static const Color historySurface = Color(0xFF1A1A1F);
  static const Color historyCardBg = Color(0xFF16161A);
  static const Color historyBorder = Color(0xFF2A2A2E);
  static const Color historyTextTopic = Color(0xFFE8E8EC);
  static const Color historyTextMuted = Color(0xFF555555);

  static const Color rankedTabBg = Color(0xFF3C3489);
  static const Color rankedTabText = Color(0xFFCECBF6);
  static const Color casualTabBg = Color(0xFF085041);
  static const Color casualTabText = Color(0xFF9FE1CB);

  static const Color accentGreen = Color(0xFF1D9E75);
  static const Color accentRed = Color(0xFFE24B4A);
  static const Color accentAmber = Color(0xFFEF9F27);

  static const Color pillPositiveBg = Color(0xFF04342C);
  static const Color pillPositiveText = Color(0xFF5DCAA5);
  static const Color pillNegativeBg = Color(0xFF501313);
  static const Color pillNegativeText = Color(0xFFF09595);

  static const Color pillRankBg = Color(0xFF26215C);
  static const Color pillRankText = Color(0xFFAFA9EC);

  static const Color pillEasyBg = Color(0xFF173404);
  static const Color pillEasyText = Color(0xFF97C459);
  static const Color pillMediumBg = Color(0xFF412402);
  static const Color pillMediumText = Color(0xFFEF9F27);
  static const Color pillHardBg = Color(0xFF501313);
  static const Color pillHardText = Color(0xFFF09595);
}
