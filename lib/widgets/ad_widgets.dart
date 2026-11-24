import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app/constants/ad_config.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import '../data/services/ads_service.dart';
import '../data/services/purchase_service.dart';

/// Anchored adaptive banner (Gameplay, Level map). Hidden for Remove Ads / VIP.
class BannerAdView extends StatelessWidget {
  const BannerAdView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (PurchaseService.to.adsRemoved || !AdsService.to.sdkReady.value) {
        return const SizedBox.shrink();
      }
      return const _BannerSlot();
    });
  }
}

class _BannerSlot extends StatefulWidget {
  const _BannerSlot();
  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      _load(MediaQuery.of(context).size.width.truncate());
    }
  }

  Future<void> _load(int width) async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) return;
    _ad = BannerAd(
      adUnitId: AdConfig.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox(height: 0);
    return Container(
      color: const Color(0xFF0A0F28),
      alignment: Alignment.center,
      width: double.infinity,
      height: ad.size.height.toDouble(),
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

/// Native ad (medium template) used in the exit dialog.
class NativeAdView extends StatefulWidget {
  const NativeAdView({super.key});
  @override
  State<NativeAdView> createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (PurchaseService.to.adsRemoved || !AdsService.to.sdkReady.value) return;
    _ad = NativeAd(
      adUnitId: AdConfig.native,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.surfaceLow,
        cornerRadius: 14,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.onGold,
          backgroundColor: AppColors.gold,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(textColor: AppColors.text, size: 15),
        secondaryTextStyle: NativeTemplateTextStyle(textColor: AppColors.muted, size: 13),
        tertiaryTextStyle: NativeTemplateTextStyle(textColor: AppColors.muted, size: 12),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) => mounted ? setState(() => _loaded = true) : null,
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null || !_loaded) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(3)),
          child: Text(
            'AD',
            style: AppText.body(10, weight: FontWeight.w800, color: AppColors.bg),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 260, maxHeight: 340),
          child: AdWidget(ad: _ad!),
        ),
      ],
    );
  }
}
