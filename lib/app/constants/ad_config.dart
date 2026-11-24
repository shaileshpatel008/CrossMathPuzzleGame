import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// AdMob configuration — see docs/ADMOB_SETUP.md.
///
/// Debug/profile builds always use Google's official test units; release builds
/// use the production IDs below. To go live:
///  1. Paste your 10 ad unit IDs into the `_prod*` constants below.
///  2. Put your AdMob **App IDs** (the ones with `~`) in
///     `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.
///  3. Add your own phones to [testDeviceIds] so they never get live ads.
class AdConfig {
  AdConfig._();

  static bool get useTestAds => !kReleaseMode;

  /// Devices that must always receive test ads, even in release builds.
  /// Run the app once with live IDs and copy the id from the log line:
  /// "Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("ABC123..."))".
  /// Clicking real ads on your own phone can get the AdMob account suspended.
  static const List<String> testDeviceIds = <String>[
    // 'ABC123DEF456...',
  ];

  /// Google's test publisher id — if it's still in a production ID, live ads aren't set up yet.
  static const _testPublisher = 'ca-app-pub-3940256099942544';

  static bool get productionIdsConfigured => ![
    _prodAndroidBanner,
    _prodAndroidInterstitial,
    _prodAndroidRewarded,
    _prodAndroidAppOpen,
    _prodAndroidNative,
    _prodIosBanner,
    _prodIosInterstitial,
    _prodIosRewarded,
    _prodIosAppOpen,
    _prodIosNative,
  ].any((id) => id.startsWith(_testPublisher));

  // ---- Production unit IDs: PASTE YOUR ADMOB AD UNIT IDS HERE (ca-app-pub-XXXX/YYYY) ----
  static const _prodAndroidBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const _prodAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _prodAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _prodAndroidAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const _prodAndroidNative = 'ca-app-pub-3940256099942544/2247696110';

  static const _prodIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _prodIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _prodIosRewarded = 'ca-app-pub-3940256099942544/1712485313';
  static const _prodIosAppOpen = 'ca-app-pub-3940256099942544/5575463023';
  static const _prodIosNative = 'ca-app-pub-3940256099942544/3986624511';

  // ---- Google test unit IDs ----
  static const _testAndroidBanner = 'ca-app-pub-3940256099942544/9214589741';
  static const _testAndroidInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testAndroidRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _testAndroidAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const _testAndroidNative = 'ca-app-pub-3940256099942544/2247696110';

  static const _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _testIosInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const _testIosRewarded = 'ca-app-pub-3940256099942544/1712485313';
  static const _testIosAppOpen = 'ca-app-pub-3940256099942544/5575463023';
  static const _testIosNative = 'ca-app-pub-3940256099942544/3986624511';

  static String _pick(String testA, String testI, String prodA, String prodI) {
    final ios = !kIsWeb && Platform.isIOS;
    if (useTestAds) return ios ? testI : testA;
    return ios ? prodI : prodA;
  }

  static String get banner => _pick(_testAndroidBanner, _testIosBanner, _prodAndroidBanner, _prodIosBanner);
  static String get interstitial =>
      _pick(_testAndroidInterstitial, _testIosInterstitial, _prodAndroidInterstitial, _prodIosInterstitial);
  static String get rewarded =>
      _pick(_testAndroidRewarded, _testIosRewarded, _prodAndroidRewarded, _prodIosRewarded);
  static String get appOpen =>
      _pick(_testAndroidAppOpen, _testIosAppOpen, _prodAndroidAppOpen, _prodIosAppOpen);
  static String get native => _pick(_testAndroidNative, _testIosNative, _prodAndroidNative, _prodIosNative);

  // ---- Frequency rules (see "Spec · Ads & in-app purchases") ----
  static const int interstitialFromLevel = 6;
  static const int interstitialEveryLevels = 2;
  static const Duration interstitialMinGap = Duration(seconds: 90);
  static const Duration appOpenMinGap = Duration(hours: 4);
  static const Duration appOpenMinBackground = Duration(seconds: 30);
  static const int appOpenFromSession = 2;
  static const Duration rewardedLoadTimeout = Duration(seconds: 8);
}
