/// Keys used with GetStorage. Keep them stable once the app ships.
class StorageKeys {
  StorageKeys._();

  // Settings
  static const settings = 'settings_v1';

  // Progress
  static const hints = 'hints';
  static const currentLevel = 'current_level';
  static const levelStars = 'level_stars';
  static const difficultyStats = 'difficulty_stats';
  static const dailySolved = 'daily_solved';
  static const solvedPerDay = 'solved_per_day';
  static const bestDailyStreak = 'best_daily_streak';
  static const achievementsClaimed = 'achievements_claimed';
  static const totalNoHintSolves = 'no_hint_solves';
  static const unlockedThemes = 'unlocked_themes';
  static const savedGame = 'saved_game';
  static const installDate = 'install_date';

  // Daily gift
  static const giftLastClaim = 'gift_last_claim';
  static const giftDay = 'gift_day';

  // Offers & prompts
  static const starterOfferStart = 'starter_offer_start';
  static const rateDone = 'rate_done';
  static const ratePromptedLevels = 'rate_prompted_levels';

  // Ads
  static const lastInterstitialMs = 'ads_last_interstitial';
  static const levelsSinceInterstitial = 'ads_levels_since_interstitial';
  static const interstitialCount = 'ads_interstitial_count';
  static const lastAppOpenMs = 'ads_last_app_open';
  static const rewardedHintsDay = 'ads_rewarded_hints_day';
  static const rewardedHintsCount = 'ads_rewarded_hints_count';
  static const unlockedDailies = 'ads_unlocked_dailies';

  // Purchases
  static const removeAds = 'iap_remove_ads';
  static const vipActive = 'iap_vip_active';
  static const vipProduct = 'iap_vip_product';
  static const deliveredPurchaseIds = 'iap_delivered_ids';
}
