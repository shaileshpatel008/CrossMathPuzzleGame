import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'vip_controller.dart';

/// Artboard 18 — VIP paywall.
class VipView extends GetView<VipController> {
  const VipView({super.key});

  static const perks = [
    'No ads, ever',
    'Unlimited hints',
    'Master mode & every past daily',
    'Free second chances',
    '4 exclusive board themes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -60,
            top: -120,
            child: Container(
              width: 510,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.violet.withValues(alpha: 0.32), AppColors.violet.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Obx(() {
              final vip = controller.iap.isVip;
              controller.iap.products.length;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      children: [
                        IconSquareButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Close',
                          color: AppColors.muted,
                          onPressed: () => Get.back(),
                        ),
                        const Spacer(),
                        TextLinkButton('Restore', color: AppColors.violetSoft, onPressed: controller.restore),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Transform.rotate(
                            angle: -0.1,
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  const BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 8)),
                                  BoxShadow(
                                    color: AppColors.gold.withValues(alpha: 0.4),
                                    blurRadius: 60,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.onGold,
                                size: 46,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'CrossMath ', style: AppText.display(30)),
                                TextSpan(
                                  text: 'VIP',
                                  style: AppText.display(30, color: AppColors.gold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vip ? 'Your membership is active' : 'Play your way. No limits.',
                            style: AppText.muted(14),
                          ),
                          const SizedBox(height: 20),
                          for (final p in perks)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              child: Row(
                                children: [
                                  const IconBadge(Icons.check_rounded, color: AppColors.mint, size: 26),
                                  const SizedBox(width: 12),
                                  Text(p, style: AppText.body(14, weight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          if (vip)
                            AppCard(
                              color: AppColors.vipSurface,
                              borderColor: AppColors.gold,
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded, color: AppColors.gold),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Active plan: ${IapIds.title(controller.iap.vipProductId.value)}',
                                      style: AppText.body(14, weight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            for (final id in [IapIds.vipYearly, IapIds.vipMonthly, IapIds.vipWeekly]) ...[
                              _plan(id),
                              const SizedBox(height: 10),
                            ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: vip
                        ? PrimaryButton(label: 'Manage subscription', onPressed: controller.manage)
                        : PrimaryButton(
                            label: controller.iap.hasFreeTrial(controller.plan.value)
                                ? 'Start 3-day free trial'
                                : 'Subscribe for ${controller.iap.price(controller.plan.value)}',
                            height: 60,
                            fontSize: 18,
                            onPressed: controller.subscribe,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 6),
                    child: Text(
                      vip
                          ? 'Change or cancel any time in Google Play › Subscriptions.'
                          : '${_legal()} Cancel anytime in Google Play › Subscriptions.',
                      textAlign: TextAlign.center,
                      style: AppText.muted(11).copyWith(height: 1.55),
                    ),
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
    );
  }

  String _legal() {
    final id = controller.plan.value;
    final price = controller.iap.price(id);
    return switch (id) {
      IapIds.vipYearly =>
        controller.iap.hasFreeTrial(id)
            ? 'Free for 3 days, then $price per year. Auto-renews.'
            : '$price per year. Auto-renews.',
      IapIds.vipMonthly => '$price per month. Auto-renews.',
      _ => '$price per week. Auto-renews.',
    };
  }

  Widget _plan(String id) {
    final on = controller.plan.value == id;
    final (name, sub, per, tag) = switch (id) {
      IapIds.vipYearly => (
        'Yearly',
        controller.iap.hasFreeTrial(id) ? '3-day free trial' : 'Billed every year',
        'per year',
        'BEST VALUE',
      ),
      IapIds.vipMonthly => ('Monthly', 'Billed every month', 'per month', null),
      _ => ('Weekly', 'Billed every week', 'per week', null),
    };
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Semantics(
          inMutuallyExclusiveGroup: true,
          checked: on,
          label: '$name plan',
          child: AppCard(
            color: on ? AppColors.vipSurface : AppColors.surface,
            borderColor: on ? AppColors.gold : AppColors.line,
            borderWidth: on ? 2 : 1,
            radius: 20,
            onTap: () => controller.plan.value = id,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg,
                    border: Border.all(color: on ? AppColors.gold : AppColors.lineDashed, width: on ? 7 : 2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.display(16)),
                      const SizedBox(height: 2),
                      Text(sub, style: AppText.muted(12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(controller.iap.price(id), style: AppText.display(17)),
                    Text(per, style: AppText.muted(11)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (tag != null)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(7)),
              child: Text(
                tag,
                style: AppText.body(10, weight: FontWeight.w800, color: AppColors.onGold),
              ),
            ),
          ),
      ],
    );
  }
}
