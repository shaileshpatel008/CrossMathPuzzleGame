import 'package:flutter/material.dart';

enum ThemeUnlock { free, dailyGift, level200, vip }

/// Board colour themes (Settings › Themes).
class GameTheme {
  const GameTheme({
    required this.id,
    required this.name,
    required this.unlock,
    required this.background,
    required this.board,
    required this.cell,
    required this.cellText,
    required this.op,
    required this.accent,
    required this.tileText,
    required this.isLight,
  });

  final String id;
  final String name;
  final ThemeUnlock unlock;
  final Color background;
  final Color board;
  final Color cell;
  final Color cellText;
  final Color op;
  final Color accent;
  final Color tileText;
  final bool isLight;

  Color get accentShadow => Color.lerp(accent, Colors.black, 0.32)!;
  Color get usedTile => isLight ? const Color(0xFFE4E1D8) : Color.lerp(board, Colors.white, 0.06)!;
  Color get usedTileText => isLight ? const Color(0xFFA09C90) : Color.lerp(board, Colors.white, 0.28)!;
  Color get emptyBorder => isLight ? const Color(0xFFB9B4A6) : Color.lerp(cell, Colors.white, 0.18)!;
  Color get highlightCell => Color.lerp(cell, accent, 0.12)!;
  Color get opCell => isLight ? Colors.transparent : Color.lerp(board, cell, 0.35)!;

  String get unlockLabel => switch (unlock) {
    ThemeUnlock.free => 'FREE',
    ThemeUnlock.dailyGift => 'DAY-7 GIFT',
    ThemeUnlock.level200 => 'LEVEL 200',
    ThemeUnlock.vip => 'VIP',
  };

  static const midnight = GameTheme(
    id: 'midnight',
    name: 'Midnight',
    unlock: ThemeUnlock.free,
    background: Color(0xFF0D1230),
    board: Color(0xFF111843),
    cell: Color(0xFF1F2858),
    cellText: Color(0xFFF3F5FF),
    op: Color(0xFF9B8CFF),
    accent: Color(0xFFFFC24B),
    tileText: Color(0xFF1A1300),
    isLight: false,
  );

  static const all = <GameTheme>[
    midnight,
    GameTheme(
      id: 'paper',
      name: 'Paper',
      unlock: ThemeUnlock.free,
      background: Color(0xFFF4F1EA),
      board: Color(0xFFEDE9DF),
      cell: Color(0xFFFFFFFF),
      cellText: Color(0xFF1C1F2E),
      op: Color(0xFF5B4CE0),
      accent: Color(0xFF1C1F2E),
      tileText: Color(0xFFFFFFFF),
      isLight: true,
    ),
    GameTheme(
      id: 'ocean',
      name: 'Ocean',
      unlock: ThemeUnlock.dailyGift,
      background: Color(0xFF0B2A3A),
      board: Color(0xFF0E3346),
      cell: Color(0xFF12405A),
      cellText: Color(0xFFE8F7FF),
      op: Color(0xFF5ED3F3),
      accent: Color(0xFF5ED3F3),
      tileText: Color(0xFF06202C),
      isLight: false,
    ),
    GameTheme(
      id: 'forest',
      name: 'Forest',
      unlock: ThemeUnlock.level200,
      background: Color(0xFF10261C),
      board: Color(0xFF142F23),
      cell: Color(0xFF1A3A2B),
      cellText: Color(0xFFEAF7EF),
      op: Color(0xFF7FE0A8),
      accent: Color(0xFFF2C94C),
      tileText: Color(0xFF1E1A05),
      isLight: false,
    ),
    GameTheme(
      id: 'sunset',
      name: 'Sunset',
      unlock: ThemeUnlock.vip,
      background: Color(0xFF2A1430),
      board: Color(0xFF34193B),
      cell: Color(0xFF43204B),
      cellText: Color(0xFFFFF0F5),
      op: Color(0xFFFF9AB8),
      accent: Color(0xFFFF9F5A),
      tileText: Color(0xFF2A0E05),
      isLight: false,
    ),
    GameTheme(
      id: 'neon',
      name: 'Neon',
      unlock: ThemeUnlock.vip,
      background: Color(0xFF07070D),
      board: Color(0xFF0E0E17),
      cell: Color(0xFF14141F),
      cellText: Color(0xFFF5F5FF),
      op: Color(0xFF00E5C3),
      accent: Color(0xFFE9FF59),
      tileText: Color(0xFF121400),
      isLight: false,
    ),
    GameTheme(
      id: 'chalk',
      name: 'Chalk',
      unlock: ThemeUnlock.vip,
      background: Color(0xFF1E2B26),
      board: Color(0xFF22312B),
      cell: Color(0xFF2A3A33),
      cellText: Color(0xFFF5F2E8),
      op: Color(0xFFC9E4D7),
      accent: Color(0xFFF5F2E8),
      tileText: Color(0xFF1E2B26),
      isLight: false,
    ),
    GameTheme(
      id: 'rose',
      name: 'Rose',
      unlock: ThemeUnlock.vip,
      background: Color(0xFFFFF1F3),
      board: Color(0xFFFCE4E9),
      cell: Color(0xFFFFFFFF),
      cellText: Color(0xFF3B1420),
      op: Color(0xFFD6336C),
      accent: Color(0xFFD6336C),
      tileText: Color(0xFFFFFFFF),
      isLight: true,
    ),
  ];

  static GameTheme byId(String id) => all.firstWhere((t) => t.id == id, orElse: () => midnight);
}
