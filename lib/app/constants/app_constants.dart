/// App-wide constants. Replace the URLs / e-mail marked TODO before release.
class AppConstants {
  AppConstants._();

  static const String appName = 'CrossMathPuzzle – Math Puzzle Game';
  static const String shortName = 'CrossMath Puzzle';
  static const String packageName = 'sp.math.puzzle.games.crossmathpuzzle.play';

  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
  static const String manageSubscriptionsUrl =
      'https://play.google.com/store/account/subscriptions?package=$packageName';

  // TODO: replace with your real pages before publishing.
  static const String privacyPolicyUrl = 'https://example.com/crossmath/privacy';
  static const String termsUrl = 'https://example.com/crossmath/terms';
  static const String supportEmail = 'support@example.com';

  // Game economy
  static const int startingHints = 3;
  static const int levelsPerChapter = 20;
  static const int levelRewardHints = 1;
  static const int chapterRewardHints = 3;
  static const int maxRewardedHintsPerDay = 5;
  static const int monthlyTrophyTarget = 25;
  static const int starterOfferUnlockLevel = 10;
  static const Duration starterOfferDuration = Duration(hours: 24);

  // Quick-play unlocks
  static const int expertUnlockLevel = 200;
  static const int masterUnlockLevel = 400;

  // Rate-us prompt after finishing these journey levels
  static const List<int> ratePromptLevels = [15, 40, 100, 250];

  // Daily reminder default time
  static const int defaultReminderHour = 19;
  static const int defaultReminderMinute = 0;

  // Daily gift rewards (hints) for day 1..7. Day 7 also unlocks the Ocean theme.
  static const List<int> dailyGiftRewards = [1, 1, 2, 2, 3, 3, 5];
}
