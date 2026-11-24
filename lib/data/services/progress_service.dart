import 'dart:math' as math;

import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/storage_keys.dart';
import '../../app/utils/formatters.dart';
import '../models/achievement.dart';
import '../models/difficulty.dart';
import '../models/game_args.dart';
import '../models/level_result.dart';
import 'storage_service.dart';

/// Per-difficulty statistics.
class DiffStats {
  int started = 0;
  int solved = 0;
  int perfect = 0;
  int hintsUsed = 0;
  int seconds = 0;
  int bestTime = 0;
  int noHintSolves = 0;

  Map<String, dynamic> toJson() => {
    'st': started,
    'so': solved,
    'pf': perfect,
    'hu': hintsUsed,
    'se': seconds,
    'bt': bestTime,
    'nh': noHintSolves,
  };

  static DiffStats fromJson(Map<String, dynamic> j) => DiffStats()
    ..started = j['st'] as int? ?? 0
    ..solved = j['so'] as int? ?? 0
    ..perfect = j['pf'] as int? ?? 0
    ..hintsUsed = j['hu'] as int? ?? 0
    ..seconds = j['se'] as int? ?? 0
    ..bestTime = j['bt'] as int? ?? 0
    ..noHintSolves = j['nh'] as int? ?? 0;

  DiffStats operator +(DiffStats o) => DiffStats()
    ..started = started + o.started
    ..solved = solved + o.solved
    ..perfect = perfect + o.perfect
    ..hintsUsed = hintsUsed + o.hintsUsed
    ..seconds = seconds + o.seconds
    ..bestTime = bestTime == 0 ? o.bestTime : (o.bestTime == 0 ? bestTime : math.min(bestTime, o.bestTime))
    ..noHintSolves = noHintSolves + o.noHintSolves;
}

/// Everything the player earns: levels, stars, hints, stats, dailies, streaks,
/// gifts, offers and achievements.
class ProgressService extends GetxService {
  static ProgressService get to => Get.find();

  StorageService get _s => StorageService.to;

  final hints = 0.obs;
  final currentLevel = 1.obs; // next journey level to play
  final levelStars = <int, int>{}.obs;
  final dailySolved = <String, int>{}.obs; // dateKey -> seconds
  final achievementsClaimed = <String>{}.obs;
  final unlockedThemes = <String>{}.obs;
  final statsVersion = 0.obs; // bump to refresh stats UIs
  final giftDay = 1.obs;
  final giftLastClaim = ''.obs;
  final starterOfferStart = 0.obs;

  final Map<Difficulty, DiffStats> _stats = {};
  final Map<String, int> _solvedPerDay = {};
  int bestDailyStreak = 0;
  late DateTime installDate;

  ProgressService init() {
    hints.value = _s.readInt(StorageKeys.hints, AppConstants.startingHints);
    currentLevel.value = _s.readInt(StorageKeys.currentLevel, 1);
    levelStars.assignAll(
      _s.readMap(StorageKeys.levelStars).map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
    );
    final st = _s.readMap(StorageKeys.difficultyStats);
    for (final d in Difficulty.values) {
      _stats[d] = st[d.name] is Map
          ? DiffStats.fromJson(Map<String, dynamic>.from(st[d.name] as Map))
          : DiffStats();
    }
    dailySolved.assignAll(_s.readMap(StorageKeys.dailySolved).map((k, v) => MapEntry(k, (v as num).toInt())));
    _solvedPerDay.addAll(_s.readMap(StorageKeys.solvedPerDay).map((k, v) => MapEntry(k, (v as num).toInt())));
    bestDailyStreak = _s.readInt(StorageKeys.bestDailyStreak);
    achievementsClaimed.addAll(_s.readStringList(StorageKeys.achievementsClaimed));
    unlockedThemes.addAll(_s.readStringList(StorageKeys.unlockedThemes));
    giftDay.value = _s.readInt(StorageKeys.giftDay, 1);
    giftLastClaim.value = _s.readString(StorageKeys.giftLastClaim) ?? '';
    starterOfferStart.value = _s.readInt(StorageKeys.starterOfferStart);
    final install = _s.readString(StorageKeys.installDate);
    if (install == null) {
      installDate = Fmt.today();
      _s.write(StorageKeys.installDate, Fmt.dateKey(installDate));
    } else {
      installDate = Fmt.parseKey(install);
    }
    ever(hints, (v) => _s.write(StorageKeys.hints, v));
    return this;
  }

  // ---------------------------------------------------------------- hints

  void addHints(int n) => hints.value += n;

  bool spendHint() {
    if (hints.value <= 0) return false;
    hints.value--;
    return true;
  }

  // ---------------------------------------------------------------- journey

  int get chapter => chapterOf(currentLevel.value);
  static int chapterOf(int level) => (level - 1) ~/ AppConstants.levelsPerChapter + 1;
  static int chapterStart(int chapter) => (chapter - 1) * AppConstants.levelsPerChapter + 1;
  int get levelInChapter => (currentLevel.value - 1) % AppConstants.levelsPerChapter;
  int get totalStars => levelStars.values.fold(0, (a, b) => a + b);
  int get maxStars => (currentLevel.value - 1) * 3;
  int starsInChapter(int chapter) {
    final s = chapterStart(chapter);
    var sum = 0;
    for (var l = s; l < s + AppConstants.levelsPerChapter; l++) {
      sum += levelStars[l] ?? 0;
    }
    return sum;
  }

  // ---------------------------------------------------------------- stats

  DiffStats stats(Difficulty d) => _stats[d]!;
  DiffStats get allStats => _stats.values.fold(DiffStats(), (a, b) => a + b);

  void recordStart(Difficulty d) {
    _stats[d]!.started++;
    _saveStats();
  }

  void _saveStats() {
    _s.write(StorageKeys.difficultyStats, {for (final e in _stats.entries) e.key.name: e.value.toJson()});
    statsVersion.value++;
  }

  /// Puzzles solved per day for the last [days] days (oldest first).
  List<int> solvedLastDays(int days) {
    final today = Fmt.today();
    return [
      for (var i = days - 1; i >= 0; i--) _solvedPerDay[Fmt.dateKey(today.subtract(Duration(days: i)))] ?? 0,
    ];
  }

  static int starsFor(int mistakes, int hintsUsed) {
    if (mistakes == 0 && hintsUsed == 0) return 3;
    if (mistakes + hintsUsed <= 1) return 2;
    return 1;
  }

  /// Records a solved puzzle and returns what the player earned.
  LevelResult completeGame(
    GameArgs args, {
    required int seconds,
    required int mistakes,
    required int hintsUsed,
    required bool relaxed,
  }) {
    final before = unclaimedAchievementIds.toSet();
    final d = args.difficulty;
    final stars = relaxed ? 1 : starsFor(mistakes, hintsUsed);
    final st = _stats[d]!;
    final newBest = !relaxed && (st.bestTime == 0 || seconds < st.bestTime);
    st.solved++;
    st.seconds += seconds;
    st.hintsUsed += hintsUsed;
    if (stars == 3) st.perfect++;
    if (hintsUsed == 0) st.noHintSolves++;
    if (newBest) st.bestTime = seconds;
    final todayKey = Fmt.todayKey();
    _solvedPerDay[todayKey] = (_solvedPerDay[todayKey] ?? 0) + 1;
    _s.write(StorageKeys.solvedPerDay, _solvedPerDay);
    _saveStats();

    var reward = 0;
    var chapterDone = false;
    if (args.mode == GameMode.journey) {
      final level = args.level!;
      final prev = levelStars[level] ?? 0;
      if (stars > prev) {
        levelStars[level] = stars;
        _s.write(StorageKeys.levelStars, levelStars.map((k, v) => MapEntry('$k', v)));
      }
      if (level >= currentLevel.value) {
        currentLevel.value = level + 1;
        _s.write(StorageKeys.currentLevel, currentLevel.value);
        reward += AppConstants.levelRewardHints;
        if (level % AppConstants.levelsPerChapter == 0) {
          chapterDone = true;
          reward += AppConstants.chapterRewardHints;
        }
        if (level >= AppConstants.starterOfferUnlockLevel && starterOfferStart.value == 0) {
          starterOfferStart.value = DateTime.now().millisecondsSinceEpoch;
          _s.write(StorageKeys.starterOfferStart, starterOfferStart.value);
        }
      }
    } else if (args.mode == GameMode.daily && !args.replay) {
      final key = Fmt.dateKey(args.date!);
      dailySolved[key] = seconds;
      _s.write(StorageKeys.dailySolved, Map<String, int>.from(dailySolved));
      bestDailyStreak = math.max(bestDailyStreak, dailyStreak);
      _s.write(StorageKeys.bestDailyStreak, bestDailyStreak);
      reward += AppConstants.levelRewardHints;
    }
    if (reward > 0) addHints(reward);

    final unlocked = unclaimedAchievementIds.where((id) => !before.contains(id)).toList();
    return LevelResult(
      args: args,
      seconds: seconds,
      mistakes: mistakes,
      hintsUsed: hintsUsed,
      stars: stars,
      rewardHints: reward,
      newBest: newBest,
      chapterCompleted: chapterDone,
      unlockedAchievements: unlocked,
      dailyStreak: dailyStreak,
    );
  }

  // ---------------------------------------------------------------- daily

  bool isDailySolved(DateTime d) => dailySolved.containsKey(Fmt.dateKey(d));

  /// Consecutive solved days ending today (or yesterday if today is not solved yet).
  int get dailyStreak {
    var day = Fmt.today();
    if (!isDailySolved(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (isDailySolved(day)) {
      n++;
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  int solvedInMonth(int year, int month) => dailySolved.keys
      .where((k) => k.startsWith('${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-'))
      .length;

  bool trophyEarned(int year, int month) => solvedInMonth(year, month) >= AppConstants.monthlyTrophyTarget;

  int get trophiesEarned {
    final months = dailySolved.keys.map((k) => k.substring(0, 7)).toSet();
    return months.where((m) {
      final p = m.split('-').map(int.parse).toList();
      return trophyEarned(p[0], p[1]);
    }).length;
  }

  // ---------------------------------------------------------------- daily gift

  bool get giftAvailable => giftLastClaim.value != Fmt.todayKey();

  /// Gift day (1..7) the player would receive today.
  int get giftDayToday {
    final yesterday = Fmt.dateKey(Fmt.today().subtract(const Duration(days: 1)));
    if (giftLastClaim.value == yesterday) return giftDay.value % 7 + 1;
    return 1;
  }

  int giftReward(int day) => AppConstants.dailyGiftRewards[(day - 1).clamp(0, 6)];

  void claimGift({int multiplier = 1}) {
    final day = giftDayToday;
    addHints(giftReward(day) * multiplier);
    if (day == 7) unlockTheme('ocean');
    giftDay.value = day;
    giftLastClaim.value = Fmt.todayKey();
    _s.write(StorageKeys.giftDay, day);
    _s.write(StorageKeys.giftLastClaim, giftLastClaim.value);
  }

  void unlockTheme(String id) {
    unlockedThemes.add(id);
    _s.write(StorageKeys.unlockedThemes, unlockedThemes.toList());
  }

  // ---------------------------------------------------------------- starter offer

  Duration get starterOfferRemaining {
    if (starterOfferStart.value == 0) return Duration.zero;
    final end = DateTime.fromMillisecondsSinceEpoch(
      starterOfferStart.value,
    ).add(AppConstants.starterOfferDuration);
    return end.difference(DateTime.now());
  }

  bool get starterOfferActive => starterOfferRemaining > Duration.zero;

  // ---------------------------------------------------------------- rate prompt

  bool shouldPromptRate(int justFinishedLevel) {
    if (_s.readBool(StorageKeys.rateDone)) return false;
    if (!AppConstants.ratePromptLevels.contains(justFinishedLevel)) return false;
    final asked = _s.readStringList(StorageKeys.ratePromptedLevels);
    if (asked.contains('$justFinishedLevel')) return false;
    _s.write(StorageKeys.ratePromptedLevels, [...asked, '$justFinishedLevel']);
    return true;
  }

  void markRated() => _s.write(StorageKeys.rateDone, true);

  // ---------------------------------------------------------------- achievements

  int metric(AchievementMetric m) => switch (m) {
    AchievementMetric.totalSolved => allStats.solved,
    AchievementMetric.journeyCompleted => currentLevel.value - 1,
    AchievementMetric.perfect => allStats.perfect,
    AchievementMetric.bestDailyStreak => math.max(bestDailyStreak, dailyStreak),
    AchievementMetric.trophies => trophiesEarned,
    AchievementMetric.fastHard =>
      (stats(Difficulty.hard).bestTime > 0 && stats(Difficulty.hard).bestTime < 180) ? 1 : 0,
    AchievementMetric.noHintSolves => allStats.noHintSolves,
    AchievementMetric.expertSolved => stats(Difficulty.expert).solved,
    AchievementMetric.masterSolved => stats(Difficulty.master).solved,
    AchievementMetric.dailySolved => dailySolved.length,
  };

  bool achievementDone(AchievementDef a) => metric(a.metric) >= a.target;

  Iterable<String> get unclaimedAchievementIds => AchievementDef.all
      .where((a) => achievementDone(a) && !achievementsClaimed.contains(a.id))
      .map((a) => a.id);

  int get achievementsUnlockedCount => AchievementDef.all.where(achievementDone).length;

  void claimAchievement(AchievementDef a) {
    if (!achievementDone(a) || achievementsClaimed.contains(a.id)) return;
    achievementsClaimed.add(a.id);
    _s.write(StorageKeys.achievementsClaimed, achievementsClaimed.toList());
    addHints(a.reward);
  }

  // ---------------------------------------------------------------- saved game

  void saveGame(String key, Map<String, dynamic> state) =>
      _s.write(StorageKeys.savedGame, {'key': key, 'state': state});

  Map<String, dynamic>? loadGame(String key) {
    final m = _s.readMap(StorageKeys.savedGame);
    if (m['key'] != key || m['state'] is! Map) return null;
    return Map<String, dynamic>.from(m['state'] as Map);
  }

  void clearGame() => _s.remove(StorageKeys.savedGame);

  // ---------------------------------------------------------------- reset

  Future<void> resetProgress() async {
    for (final k in [
      StorageKeys.currentLevel,
      StorageKeys.levelStars,
      StorageKeys.difficultyStats,
      StorageKeys.dailySolved,
      StorageKeys.solvedPerDay,
      StorageKeys.bestDailyStreak,
      StorageKeys.achievementsClaimed,
      StorageKeys.savedGame,
      StorageKeys.ratePromptedLevels,
    ]) {
      await _s.remove(k);
    }
    currentLevel.value = 1;
    levelStars.clear();
    dailySolved.clear();
    _solvedPerDay.clear();
    bestDailyStreak = 0;
    achievementsClaimed.clear();
    for (final d in Difficulty.values) {
      _stats[d] = DiffStats();
    }
    statsVersion.value++;
  }
}
