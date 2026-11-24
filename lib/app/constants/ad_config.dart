import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// AdMob configuration.
///
/// Debug builds always use Google's official test units. Before releasing,
/// paste your own unit IDs into the `_prod*` constants below and set the
/// AdMob App ID in `android/app/src/main/AndroidManifest.xml` and
/// `ios/Runner/Info.plist`.
class AdConfig {
  AdConfig._();

  static bool get useTestAds => !kReleaseMode;

  // ---- Production unit IDs (TODO: replace) ----
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
