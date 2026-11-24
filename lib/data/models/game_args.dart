import 'difficulty.dart';

enum GameMode { journey, quick, daily }

/// Arguments passed to the game screen.
class GameArgs {
  const GameArgs._(this.mode, this.difficulty, this.seed, {this.level, this.date, this.replay = false});

  factory GameArgs.journey(int level, {bool replay = false}) => GameArgs._(
    GameMode.journey,
    DifficultyX.forLevel(level),
    level * 7919 + 104729,
    level: level,
    replay: replay,
  );

  factory GameArgs.quick(Difficulty d) =>
      GameArgs._(GameMode.quick, d, DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF);

  /// Daily: Hard Mon–Sat, Expert on Sunday. Same seed worldwide.
  factory GameArgs.daily(DateTime date, {bool replay = false}) => GameArgs._(
    GameMode.daily,
    date.weekday == DateTime.sunday ? Difficulty.expert : Difficulty.hard,
    (date.year * 10000 + date.month * 100 + date.day) * 31 + 17,
    date: DateTime(date.year, date.month, date.day),
    replay: replay,
  );

  final GameMode mode;
  final Difficulty difficulty;
  final int seed;
  final int? level;
  final DateTime? date;

  /// Replaying an already-solved journey level or daily (no progress change).
  final bool replay;

  double get tierProgress => switch (mode) {
    GameMode.journey => DifficultyX.progressInTier(level!),
    GameMode.quick => 0.5,
    GameMode.daily => 0.6,
  };

  /// Identifies a game so an in-progress board can be resumed.
  String get key => switch (mode) {
    GameMode.journey => 'j$level',
    GameMode.quick => 'q${difficulty.name}',
    GameMode.daily => 'd${date!.year}-${date!.month}-${date!.day}',
  };

  String get title => switch (mode) {
    GameMode.journey => 'Level $level',
    GameMode.quick => 'Quick Play',
    GameMode.daily => 'Daily Challenge',
  };
}
