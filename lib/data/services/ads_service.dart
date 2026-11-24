import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app/constants/ad_config.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/storage_keys.dart';
import '../../app/routes/app_routes.dart';
import '../../app/utils/formatters.dart';
import 'connectivity_service.dart';
import 'purchase_service.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// AdMob: UMP consent, app-open, banner (widget), interstitial, rewarded and
/// native (widget). All non-rewarded formats are suppressed for Remove Ads / VIP.
class AdsService extends GetxService {
  static AdsService get to => Get.find();

  StorageService get _s => StorageService.to;
  PurchaseService get _iap => PurchaseService.to;

  final sdkReady = false.obs;
  final privacyOptionsRequired = false.obs;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  AppOpenAd? _appOpen;
  DateTime? _appOpenLoadedAt;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  bool _loadingAppOpen = false;
  bool _fullScreenShowing = false;
  DateTime? _backgroundedAt;

  /// Set while a purchase / external flow is active so no app-open ad interrupts it.
  bool suppressAppOpen = false;

  bool get adsRemoved => _iap.adsRemoved;
  bool get isFullScreenShowing => _fullScreenShowing;

  // ------------------------------------------------------------------ consent

  /// Runs the UMP consent flow (form only shown where required, e.g. EEA/UK),
  /// then initialises the Mobile Ads SDK if ads may be requested.
  Future<void> gatherConsentAndInit() async {
    final done = Completer<void>();
    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () {
          ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) {
            if (e != null) debugPrint('Consent form: ${e.message}');
            if (!done.isCompleted) done.complete();
          });
        },
        (FormError e) {
          debugPrint('Consent info update failed: ${e.message}');
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future.timeout(const Duration(seconds: 20), onTimeout: () {});
      privacyOptionsRequired.value =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      debugPrint('Consent flow error: $e');
    }
    await _initSdkIfAllowed();
  }

  Future<void> _initSdkIfAllowed() async {
    if (sdkReady.value) return;
    try {
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      sdkReady.value = true;
      _preloadAll();
      await AppStateEventNotifier.startListening();
      AppStateEventNotifier.appStateStream.listen(_onAppState);
      ever(_iap.removeAdsOwned, (_) => _onEntitlementChanged());
      ever(_iap.vipActive, (_) => _onEntitlementChanged());
    } catch (e) {
      debugPrint('MobileAds init failed: $e');
    }
  }

  /// Settings › Privacy options (ads consent).
  Future<bool> showPrivacyOptions() async {
    if (!privacyOptionsRequired.value) return false;
    final c = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? e) {
      if (!c.isCompleted) c.complete();
    });
    await c.future;
    await _initSdkIfAllowed();
    return true;
  }

  void _onEntitlementChanged() {
    if (adsRemoved) {
      _interstitial?.dispose();
      _interstitial = null;
      _appOpen?.dispose();
      _appOpen = null;
    }
  }

  void _preloadAll() {
    _loadRewarded();
    if (!adsRemoved) {
      _loadInterstitial();
      _loadAppOpen();
    }
  }

  // ------------------------------------------------------------- interstitial

  void _loadInterstitial() {
    if (!sdkReady.value || adsRemoved || _interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (e) {
          _loadingInterstitial = false;
          debugPrint('Interstitial failed: ${e.message}');
        },
      ),
    );
  }

  /// Called after every solved puzzle.
  void onPuzzleCompleted() {
    _s.write(StorageKeys.levelsSinceInterstitial, _s.readInt(StorageKeys.levelsSinceInterstitial) + 1);
  }

  bool interstitialDue({int? journeyLevel}) {
    if (adsRemoved || !sdkReady.value || _interstitial == null) return false;
    if (journeyLevel != null && journeyLevel < AdConfig.interstitialFromLevel) return false;
    if (_s.readInt(StorageKeys.levelsSinceInterstitial) < AdConfig.interstitialEveryLevels) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(_s.readInt(StorageKeys.lastInterstitialMs));
    return DateTime.now().difference(last) >= AdConfig.interstitialMinGap;
  }

  /// Shows the "Ad break" screen (with the Remove-Ads offer) followed by the
  /// interstitial, if one is due. Returns true if the player chose Remove Ads.
  Future<bool> maybeShowInterstitial({int? journeyLevel}) async {
    if (!interstitialDue(journeyLevel: journeyLevel)) {
      _loadInterstitial();
      return false;
    }
    final result = await Get.toNamed(Routes.adBreak);
    return result == 'remove_ads';
  }

  /// Shows the loaded interstitial and waits for it to close.
  Future<void> showInterstitialNow() async {
    final ad = _interstitial;
    if (ad == null || adsRemoved) return;
    _interstitial = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _fullScreenShowing = true,
      onAdDismissedFullScreenContent: (a) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show();
    await closed.future;
    _s.write(StorageKeys.lastInterstitialMs, DateTime.now().millisecondsSinceEpoch);
    _s.write(StorageKeys.levelsSinceInterstitial, 0);
    _s.write(StorageKeys.interstitialCount, _s.readInt(StorageKeys.interstitialCount) + 1);
    _loadInterstitial();
  }

  // ----------------------------------------------------------------- rewarded

  void _loadRewarded() {
    if (!sdkReady.value || _rewarded != null || _loadingRewarded) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingRewarded = false;
          _rewarded = ad;
        },
        onAdFailedToLoad: (e) {
          _loadingRewarded = false;
          debugPrint('Rewarded failed: ${e.message}');
        },
      ),
    );
  }

  /// Shows a reward video. Resolves to true only if the reward was earned.
  /// Returns null when no video could be loaded (offline / no fill).
  Future<bool?> showRewarded() async {
    if (!ConnectivityService.to.online.value) return null;
    if (!sdkReady.value) await _initSdkIfAllowed();
    if (!sdkReady.value) return null;
    if (_rewarded == null) {
      _loadRewarded();
      final deadline = DateTime.now().add(AdConfig.rewardedLoadTimeout);
      while (_rewarded == null && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (!_loadingRewarded && _rewarded == null) break;
      }
    }
    final ad = _rewarded;
    if (ad == null) return null;
    _rewarded = null;
    var earned = false;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _fullScreenShowing = true,
      onAdDismissedFullScreenContent: (a) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    await closed.future;
    _loadRewarded();
    return earned;
  }

  int get rewardedHintsLeftToday {
    if (_s.readString(StorageKeys.rewardedHintsDay) != Fmt.todayKey()) {
      return AppConstants.maxRewardedHintsPerDay;
    }
    return (AppConstants.maxRewardedHintsPerDay - _s.readInt(StorageKeys.rewardedHintsCount)).clamp(
      0,
      AppConstants.maxRewardedHintsPerDay,
    );
  }

  void noteRewardedHint() {
    final today = Fmt.todayKey();
    final count = _s.readString(StorageKeys.rewardedHintsDay) == today
        ? _s.readInt(StorageKeys.rewardedHintsCount)
        : 0;
    _s.write(StorageKeys.rewardedHintsDay, today);
    _s.write(StorageKeys.rewardedHintsCount, count + 1);
  }

  // Missed dailies unlocked with a video
  bool isDailyUnlocked(String key) => _s.readStringList(StorageKeys.unlockedDailies).contains(key);
  void unlockDaily(String key) =>
      _s.write(StorageKeys.unlockedDailies, [..._s.readStringList(StorageKeys.unlockedDailies), key]);

  // ----------------------------------------------------------------- app open

  void _loadAppOpen() {
    if (!sdkReady.value || adsRemoved || _appOpen != null || _loadingAppOpen) return;
    _loadingAppOpen = true;
    AppOpenAd.load(
      adUnitId: AdConfig.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingAppOpen = false;
          _appOpen = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (e) {
          _loadingAppOpen = false;
          debugPrint('App open failed: ${e.message}');
        },
      ),
    );
  }

  bool get _appOpenFresh =>
      _appOpen != null &&
      _appOpenLoadedAt != null &&
      DateTime.now().difference(_appOpenLoadedAt!) < const Duration(hours: 4);

  /// App-open ad: from the 2nd session, at most once per 4 hours.
  Future<void> maybeShowAppOpen() async {
    if (adsRemoved || suppressAppOpen || _fullScreenShowing || !sdkReady.value) return;
    if (SettingsService.to.sessionCount.value < AdConfig.appOpenFromSession) return;
    final last = DateTime.fromMillisecondsSinceEpoch(_s.readInt(StorageKeys.lastAppOpenMs));
    if (DateTime.now().difference(last) < AdConfig.appOpenMinGap) return;
    if (!_appOpenFresh) {
      _appOpen?.dispose();
      _appOpen = null;
      _loadAppOpen();
      return;
    }
    final ad = _appOpen!;
    _appOpen = null;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _fullScreenShowing = true,
      onAdDismissedFullScreenContent: (a) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (a, e) {
        _fullScreenShowing = false;
        a.dispose();
        if (!closed.isCompleted) closed.complete();
      },
    );
    _s.write(StorageKeys.lastAppOpenMs, DateTime.now().millisecondsSinceEpoch);
    await ad.show();
    await closed.future;
    _loadAppOpen();
  }

  void _onAppState(AppState state) {
    if (state == AppState.background) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppState.foreground) {
      final away = _backgroundedAt == null ? Duration.zero : DateTime.now().difference(_backgroundedAt!);
      _backgroundedAt = null;
      if (away >= AdConfig.appOpenMinBackground) maybeShowAppOpen();
    }
  }
}
