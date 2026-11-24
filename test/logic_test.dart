import 'package:crossmath_puzzle/app/utils/formatters.dart';
import 'package:crossmath_puzzle/data/models/difficulty.dart';
import 'package:crossmath_puzzle/data/models/game_args.dart';
import 'package:crossmath_puzzle/data/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stars: 3 = flawless, 2 = one slip, 1 = solved', () {
    expect(ProgressService.starsFor(0, 0), 3);
    expect(ProgressService.starsFor(1, 0), 2);
    expect(ProgressService.starsFor(0, 1), 2);
    expect(ProgressService.starsFor(1, 1), 1);
    expect(ProgressService.starsFor(3, 0), 1);
  });

  test('journey levels map to tiers and ramp inside a tier', () {
    expect(DifficultyX.forLevel(1), Difficulty.tutorial);
    expect(DifficultyX.forLevel(6), Difficulty.easy);
    expect(DifficultyX.forLevel(61), Difficulty.medium);
    expect(DifficultyX.forLevel(128), Difficulty.hard);
    expect(DifficultyX.forLevel(401), Difficulty.expert);
    expect(DifficultyX.forLevel(1500), Difficulty.master);
    expect(DifficultyX.progressInTier(121), 0);
    expect(DifficultyX.progressInTier(400), 1);
    expect(DifficultyX.progressInTier(260), inExclusiveRange(0.4, 0.6));
  });

  test('chapters hold 20 levels', () {
    expect(ProgressService.chapterOf(1), 1);
    expect(ProgressService.chapterOf(20), 1);
    expect(ProgressService.chapterOf(128), 7);
    expect(ProgressService.chapterStart(7), 121);
  });

  test('daily: Hard on weekdays, Expert on Sunday, same seed for everyone', () {
    final tue = GameArgs.daily(DateTime(2026, 11, 24));
    final sun = GameArgs.daily(DateTime(2026, 11, 22));
    expect(tue.difficulty, Difficulty.hard);
    expect(sun.difficulty, Difficulty.expert);
    expect(GameArgs.daily(DateTime(2026, 11, 24, 18)).seed, tue.seed);
    expect(tue.key, isNot(sun.key));
  });

  test('formatters', () {
    expect(Fmt.time(65), '1:05');
    expect(Fmt.time(3725), '1:02:05');
    expect(Fmt.dateKey(DateTime(2026, 1, 5)), '2026-01-05');
    expect(Fmt.parseKey('2026-11-24'), DateTime(2026, 11, 24));
    expect(Fmt.countdown(const Duration(hours: 23, minutes: 59, seconds: 12)), '23:59:12');
  });
}
