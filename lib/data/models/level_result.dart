import 'game_args.dart';

/// Outcome of a solved puzzle, shown on Level complete / Daily complete.
class LevelResult {
  LevelResult({
    required this.args,
    required this.seconds,
    required this.mistakes,
    required this.hintsUsed,
    required this.stars,
    required this.rewardHints,
    required this.newBest,
    required this.chapterCompleted,
    required this.unlockedAchievements,
    required this.dailyStreak,
  });

  final GameArgs args;
  final int seconds;
  final int mistakes;
  final int hintsUsed;
  final int stars;
  final int rewardHints;
  final bool newBest;
  final bool chapterCompleted;
  final List<String> unlockedAchievements;
  final int dailyStreak;

  /// Rewarded "×3" bonus may be claimed once.
  bool bonusClaimed = false;
}
