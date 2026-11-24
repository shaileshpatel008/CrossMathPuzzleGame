import 'package:flutter/material.dart';

/// "Midnight Gold" palette — see the Design system board.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF0D1230);
  static const bgDeep = Color(0xFF060920);
  static const surface = Color(0xFF161D45);
  static const surface2 = Color(0xFF1F2858);
  static const surfaceLow = Color(0xFF111843);
  static const line = Color(0xFF2C3670);
  static const lineSoft = Color(0xFF232C62);
  static const lineDashed = Color(0xFF3A4588);

  static const text = Color(0xFFF3F5FF);
  static const muted = Color(0xFFA8B0DC);
  static const dim = Color(0xFF7A84BE);
  static const disabled = Color(0xFF4E5896);

  static const gold = Color(0xFFFFC24B);
  static const goldShadow = Color(0xFFB9820F);
  static const onGold = Color(0xFF1A1300);

  static const mint = Color(0xFF34D399);
  static const mintShadow = Color(0xFF1F9C6E);
  static const onMint = Color(0xFF062B1E);

  static const coral = Color(0xFFFF6B6B);
  static const onCoral = Color(0xFF2B0707);

  static const violet = Color(0xFF9B8CFF);
  static const violetShadow = Color(0xFF6A5BD6);
  static const violetSoft = Color(0xFFC9C2FF);
  static const vipSurface = Color(0xFF1E1A44);
  static const vipLine = Color(0xFF4A3F8F);
  static const vipHero = Color(0xFF3D2F9E);

  static const ember = Color(0xFFFF9F5A);
  static const sky = Color(0xFF60A5FA);

  static Color tierColor(int tierIndex) =>
      const [muted, mint, sky, ember, coral, violet][tierIndex.clamp(0, 5)];
}
