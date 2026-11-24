import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'store_controller.dart';

/// Artboard 17 — Store.
class StoreView extends GetView<StoreController> {
  const StoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final iap = controller.iap;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Store',
              actions: [
                TextButton.icon(
                  onPressed: controller.restore,
                  icon: const Icon(Icons.restore_rounded, size: 18, color: AppColors.gold),
                  label: Text(
                    'Restore',
                    style: AppText.body(14, weight: FontWeight.w700, color: AppColors.gold),
                  ),
                ),
              ],
            ),
            const OfflineBanner(),
            Expanded(
              child: Obx(() {
                iap.products.length;
                final vip = iap.isVip;
                final noAds = iap.removeAdsOwned.value;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    AppCard(
                      radius: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold),
                          const SizedBox(width: 10),
                          Expanded(child: Text('Your hints', style: AppText.muted(14))),
                          Text(vip ? '∞' : '${controller.progress.hints.value}', style: AppText.display(20)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _vipBanner(vip),
                    const SectionLabel('One-time purchases', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                    _oneTime(
                      icon: Icons.verified_user_rounded,
                      color: AppColors.gold,
                      title: 'Remove Ads',
                      subtitle: 'No banners, pop-up or app-open ads. Forever.',
                      owned: noAds || vip,
                      ownedLabel: vip && !noAds ? 'Included in VIP' : 'Owned',
                      price: iap.price(IapIds.removeAds),
                      onTap: () => controller.buy(IapIds.removeAds),
                    ),
                    if (controller.progress.starterOfferActive && !noAds) ...[
                      const SizedBox(height: 14),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _oneTime(
                            icon: Icons.card_giftcard_rounded,
                            color: AppColors.violet,
                            title: 'Starter Pack',
                            subtitle: 'Remove Ads + 30 hints · ends in ${controller.countdown.value}',
                            owned: false,
                            price: iap.price(IapIds.starterPack),
                            highlight: true,
                            onTap: () => controller.buy(IapIds.starterPack),
                          ),
                          Positioned(
                            top: -10,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.coral,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                '−40% · ONE-TIME OFFER',
                                style: AppText.body(10, weight: FontWeight.w800, color: AppColors.onCoral),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SectionLabel('Hint packs', padding: EdgeInsets.fromLTRB(4, 22, 4, 12)),
                    Row(
                      children: [
                        _pack(IapIds.hints10, 10, null),
                        _pack(IapIds.hints50, 50, 'POPULAR'),
                        _pack(IapIds.hints150, 150, 'BEST VALUE'),
                      ],
                    ),
                    const SectionLabel('Free', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                    AppCard(
                      color: AppColors.mint.withValues(alpha: 0.10),
                      borderColor: AppColors.mint.withValues(alpha: 0.45),
                      borderWidth: 1.5,
                      radius: 20,
                      onTap: controller.freeLeft.value > 0 ? controller.freeHint : null,
                      child: Row(
                        children: [
                          const IconBadge(Icons.smart_display_rounded, color: AppColors.mint, filled: true),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Watch a video', style: AppText.display(15)),
                                const SizedBox(height: 2),
                                Text(
                                  controller.freeLeft.value > 0
                                      ? '+1 hint · ${controller.freeLeft.value} of ${AppConstants.maxRewardedHintsPerDay} left today'
                                      : 'Daily limit reached — back tomorrow',
                                  style: AppText.muted(12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'FREE',
                            style: AppText.body(13, weight: FontWeight.w800, color: AppColors.mint),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Prices are shown in your local currency by Google Play. Purchases are tied to your Google '
                      'account and can be restored on any device. Subscriptions renew automatically unless '
                      'cancelled in Google Play › Subscriptions.',
                      textAlign: TextAlign.center,
                      style: AppText.muted(11).copyWith(height: 1.6),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextLinkButton(
                          'Terms',
                          color: AppColors.gold,
                          onPressed: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
                        ),
                        Text('·', style: AppText.muted(12)),
                        TextLinkButton(
                          'Privacy',
                          color: AppColors.gold,
                          onPressed: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl)),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vipBanner(bool vip) => Material(
    color: AppColors.vipHero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
      side: const BorderSide(color: AppColors.violetShadow),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Get.toNamed(Routes.vip),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -14,
            child: Transform.rotate(
              angle: 0.24,
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'CROSSMATH VIP',
                    style: AppText.label(color: AppColors.onGold).copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  vip ? "You're a VIP member" : 'No ads. Unlimited hints.\nEvery mode unlocked.',
                  style: AppText.display(22, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  vip
                      ? 'Thanks for your support — every perk is active.'
                      : '3 days free, then ${PurchaseService.to.price(IapIds.vipYearly)} / year',
                  style: AppText.body(13, color: const Color(0xFFDCD6FF)),
                ),
                const SizedBox(height: 14),
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    vip ? 'Manage membership' : 'Start free trial',
                    style: AppText.display(15, color: const Color(0xFF2A1F7A)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _oneTime({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool owned,
    String ownedLabel = 'Owned',
    required String price,
    bool highlight = false,
    required VoidCallback onTap,
  }) => AppCard(
    borderColor: highlight ? AppColors.gold : AppColors.line,
    borderWidth: highlight ? 1.5 : 1,
    onTap: owned ? null : onTap,
    child: Row(
      children: [
        IconBadge(icon, color: color, size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.display(16)),
              const SizedBox(height: 3),
              Text(subtitle, style: AppText.muted(12).copyWith(height: 1.4)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        owned
            ? Text(
                ownedLabel,
                style: AppText.body(13, weight: FontWeight.w700, color: AppColors.mint),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(13)),
                child: Text(
                  price,
                  style: AppText.body(14, weight: FontWeight.w800, color: AppColors.onGold),
                ),
              ),
      ],
    ),
  );

  Widget _pack(String id, int n, String? tag) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          AppCard(
            radius: 20,
            borderColor: tag == 'POPULAR' ? AppColors.violet : AppColors.line,
            borderWidth: tag == 'POPULAR' ? 1.5 : 1,
            padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
            onTap: () => controller.buy(id),
            child: Column(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold),
                const SizedBox(height: 4),
                Text('$n', style: AppText.display(24)),
                Text('hints', style: AppText.muted(12)),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    controller.iap.price(id),
                    style: AppText.body(14, weight: FontWeight.w800, color: AppColors.onGold),
                  ),
                ),
              ],
            ),
          ),
          if (tag != null)
            Positioned(
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.violet, borderRadius: BorderRadius.circular(7)),
                child: Text(
                  tag,
                  style: AppText.body(10, weight: FontWeight.w800, color: AppColors.bg),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
