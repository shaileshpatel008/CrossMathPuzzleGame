/// Google Play Console product IDs. Create these exact IDs in Play Console
/// (Monetize › Products). Prices shown here are only fallbacks used while the
/// store is loading — real, localised prices always come from Google Play.
class IapIds {
  IapIds._();

  // One-time (non-consumable)
  static const String removeAds = 'remove_ads';
  static const String starterPack = 'starter_pack';

  // Consumables
  static const String hints10 = 'hints_10';
  static const String hints50 = 'hints_50';
  static const String hints150 = 'hints_150';

  // Auto-renewing subscriptions (one base plan each; yearly has a 3-day free trial offer)
  static const String vipWeekly = 'vip_weekly';
  static const String vipMonthly = 'vip_monthly';
  static const String vipYearly = 'vip_yearly';

  static const Set<String> nonConsumables = {removeAds, starterPack};
  static const Set<String> consumables = {hints10, hints50, hints150};
  static const Set<String> subscriptions = {vipWeekly, vipMonthly, vipYearly};
  static Set<String> get all => {...nonConsumables, ...consumables, ...subscriptions};

  static const Map<String, int> hintAmounts = {hints10: 10, hints50: 50, hints150: 150, starterPack: 30};

  static const Map<String, String> fallbackPrices = {
    removeAds: r'$3.99',
    starterPack: r'$4.99',
    hints10: r'$0.99',
    hints50: r'$2.99',
    hints150: r'$6.99',
    vipWeekly: r'$1.99',
    vipMonthly: r'$4.99',
    vipYearly: r'$19.99',
  };

  static String title(String id) => switch (id) {
    removeAds => 'Remove Ads',
    starterPack => 'Starter Pack',
    hints10 => '10 Hints',
    hints50 => '50 Hints',
    hints150 => '150 Hints',
    vipWeekly => 'VIP · Weekly',
    vipMonthly => 'VIP · Monthly',
    vipYearly => 'VIP · Yearly',
    _ => id,
  };
}
