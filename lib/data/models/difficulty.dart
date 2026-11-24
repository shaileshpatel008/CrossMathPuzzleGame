import 'dart:ui' show Color;

import '../../app/theme/app_colors.dart';

/// Operators used in puzzles (stored as display characters).
class Ops {
  Ops._();
  static const add = '+';
  static const sub = '−';
  static const mul = '×';
  static const div = '÷';
  static const eq = '=';
}

enum Difficulty { tutorial, easy, medium, hard, expert, master }

/// Tuning for one difficulty tier (see "Spec · Levels & difficulty").
class DifficultyConfig {
  const DifficultyConfig({
    required this.maxWidth,
    required this.maxHeight,
    required this.ops,
    required this.maxNumber,
    required this.minEquations,
    required this.maxEquations,
    required this.longEquationChance,
    required this.blankRatioMin,
    required this.blankRatioMax,
    required this.decoys,
    required this.mistakeLimit,
    required this.forceAutoCheckOff,
  });

  final int maxWidth;
  final int maxHeight;
  final List<String> ops;
  final int maxNumber;
  final int minEquations;
  final int maxEquations;

  /// Chance that a new equation is the long 7-cell form (a ∘ b ∘ c = d).
  final double longEquationChance;
  final double blankRatioMin;
  final double blankRatioMax;

  /// Extra tiles in the tray that belong nowhere.
  final int decoys;

  /// 0 = unlimited.
  final int mistakeLimit;
  final bool forceAutoCheckOff;
}

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.tutorial => 'Tutorial',
    Difficulty.easy => 'Easy',
    Difficulty.medium => 'Medium',
    Difficulty.hard => 'Hard',
    Difficulty.expert => 'Expert',
    Difficulty.master => 'Master',
  };

  Color get color => AppColors.tierColor(index);

  String get gridLabel => '${config.maxWidth}×${config.maxHeight}';

  String get description => switch (this) {
    Difficulty.tutorial => 'Learn the basics',
    Difficulty.easy => '+ − · numbers up to 30',
    Difficulty.medium => '+ − × · numbers up to 60',
    Difficulty.hard => 'All four operators · up to 100',
    Difficulty.expert => 'Long equations · decoy tiles',
    Difficulty.master => '2 mistakes max · up to 999',
  };

  DifficultyConfig get config => switch (this) {
    Difficulty.tutorial => const DifficultyConfig(
      maxWidth: 5,
      maxHeight: 5,
      ops: [Ops.add, Ops.sub],
      maxNumber: 10,
      minEquations: 2,
      maxEquations: 3,
      longEquationChance: 0,
      blankRatioMin: 0.2,
      blankRatioMax: 0.3,
      decoys: 0,
      mistakeLimit: 0,
      forceAutoCheckOff: false,
    ),
    Difficulty.easy => const DifficultyConfig(
      maxWidth: 7,
      maxHeight: 7,
      ops: [Ops.add, Ops.sub],
      maxNumber: 30,
      minEquations: 3,
      maxEquations: 5,
      longEquationChance: 0,
      blankRatioMin: 0.3,
      blankRatioMax: 0.45,
      decoys: 0,
      mistakeLimit: 3,
      forceAutoCheckOff: false,
    ),
    Difficulty.medium => const DifficultyConfig(
      maxWidth: 7,
      maxHeight: 7,
      ops: [Ops.add, Ops.sub, Ops.mul],
      maxNumber: 60,
      minEquations: 4,
      maxEquations: 6,
      longEquationChance: 0,
      blankRatioMin: 0.4,
      blankRatioMax: 0.5,
      decoys: 0,
      mistakeLimit: 3,
      forceAutoCheckOff: false,
    ),
    Difficulty.hard => const DifficultyConfig(
      maxWidth: 9,
      maxHeight: 9,
      ops: [Ops.add, Ops.sub, Ops.mul, Ops.div],
      maxNumber: 100,
      minEquations: 6,
      maxEquations: 9,
      longEquationChance: 0,
      blankRatioMin: 0.52,
      blankRatioMax: 0.66,
      decoys: 0,
      mistakeLimit: 3,
      forceAutoCheckOff: false,
    ),
    Difficulty.expert => const DifficultyConfig(
      maxWidth: 11,
      maxHeight: 11,
      ops: [Ops.add, Ops.sub, Ops.mul, Ops.div],
      maxNumber: 200,
      minEquations: 10,
      maxEquations: 15,
      longEquationChance: 0.4,
      blankRatioMin: 0.58,
      blankRatioMax: 0.72,
      decoys: 2,
      mistakeLimit: 3,
      forceAutoCheckOff: false,
    ),
    Difficulty.master => const DifficultyConfig(
      maxWidth: 13,
      maxHeight: 13,
      ops: [Ops.add, Ops.sub, Ops.mul, Ops.div],
      maxNumber: 999,
      minEquations: 17,
      maxEquations: 24,
      longEquationChance: 0.5,
      blankRatioMin: 0.64,
      blankRatioMax: 0.78,
      decoys: 4,
      mistakeLimit: 2,
      forceAutoCheckOff: true,
    ),
  };

  /// First journey level of this tier.
  int get firstLevel => switch (this) {
    Difficulty.tutorial => 1,
    Difficulty.easy => 6,
    Difficulty.medium => 61,
    Difficulty.hard => 121,
    Difficulty.expert => 401,
    Difficulty.master => 1001,
  };

  /// Last journey level of this tier (master is open ended).
  int get lastLevel => switch (this) {
    Difficulty.tutorial => 5,
    Difficulty.easy => 60,
    Difficulty.medium => 120,
    Difficulty.hard => 400,
    Difficulty.expert => 1000,
    Difficulty.master => 2000,
  };

  static Difficulty forLevel(int level) {
    for (final d in Difficulty.values.reversed) {
      if (level >= d.firstLevel) return d;
    }
    return Difficulty.tutorial;
  }

  /// 0..1 progress inside the tier for a journey level — puzzles ramp up.
  static double progressInTier(int level) {
    final d = forLevel(level);
    final span = (d.lastLevel - d.firstLevel).clamp(1, 1 << 30);
    return ((level - d.firstLevel) / span).clamp(0.0, 1.0);
  }

  static Difficulty? tryParse(String? name) {
    for (final d in Difficulty.values) {
      if (d.name == name) return d;
    }
    return null;
  }
}
