import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants/iap_config.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/common.dart';
import 'ad_break_controller.dart';

/// Artboard 16 — short "Ad break" notice with the Remove-Ads offer, then the
/// AdMob interstitial. Pops with 'remove_ads' if the player taps the offer.

class AdBreakView extends GetView<AdBreakController> {
  const AdBreakView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF05060F),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AD BREAK',
                        style: AppText.body(11, weight: FontWeight.w800, color: AppColors.bg),
                      ),
                    ),
                    const Spacer(),
                    Obx(() => Text('Starting in ${controller.countdown.value}…', style: AppText.muted(13))),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.smart_display_rounded, size: 64, color: AppColors.dim),
                const SizedBox(height: 14),
                Text('Quick ad break', style: AppText.display(22)),
                const SizedBox(height: 8),
                Text(
                  'Ads keep CrossMath Puzzle free. Your next level starts right after.',
                  textAlign: TextAlign.center,
                  style: AppText.muted(14).copyWith(height: 1.5),
                ),
                const Spacer(),
                AppCard(
                  radius: 20,
                  onTap: controller.removeAds,
                  child: Row(
                    children: [
                      const IconBadge(Icons.shield_rounded, color: AppColors.gold, size: 40, filled: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tired of ads?', style: AppText.body(14, weight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Remove them forever, one-time purchase', style: AppText.muted(12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          PurchaseService.to.price(IapIds.removeAds),
                          style: AppText.body(13, weight: FontWeight.w800, color: AppColors.onGold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
