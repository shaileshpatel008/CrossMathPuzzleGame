import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../data/models/difficulty.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/decorations.dart';
import 'home_controller.dart';

/// Artboard 06 — Home.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.onBackPressed();
      },
      child: Scaffold(
        body: DotBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(),
                const OfflineBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        _hero(),
                        const SizedBox(height: 16),
                        _modes(),
                        const SizedBox(height: 12),
                        _promo(),
                      ],
                    ),
                  ),
                ),
                _nav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
    child: Row(
      children: [
        const LogoMark(size: 40),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CrossMath', style: AppText.display(17)),
            Text('PUZZLE', style: AppText.label().copyWith(fontSize: 11, letterSpacing: 2)),
          ],
        ),
        const Spacer(),
        const HintPill(),
        Obx(
          () => IconSquareButton(
            icon: Icons.workspace_premium_rounded,
            tooltip: controller.iap.isVip ? 'VIP active' : 'VIP membership',
            color: controller.iap.isVip ? AppColors.gold : AppColors.violet,
            onPressed: () => Get.toNamed(Routes.vip),
          ),
        ),
        IconSquareButton(
          icon: Icons.tune_rounded,
          tooltip: 'Settings',
          color: AppColors.muted,
          onPressed: () => Get.toNamed(Routes.settings),
        ),
      ],
    ),
  );

  Widget _hero() => Obx(() {
    final tier = controller.tier;
    final lvl = controller.level;
    return AppCard(
      radius: 28,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHAPTER ${controller.chapter} · ${tier.label.toUpperCase()}',
                      style: AppText.label(color: tier.color),
                    ),
                    const SizedBox(height: 6),
                    Text(lvl == 1 ? 'Tutorial' : 'Level $lvl', style: AppText.display(38, height: 1)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      '${controller.progress.totalStars}',
                      style: AppText.body(13, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const MiniBoard(cell: 30)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -4, duration: const Duration(seconds: 2), curve: Curves.easeInOut),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Chapter progress', style: AppText.muted(12, weight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${controller.levelInChapter} / ${AppConstants.levelsPerChapter} levels',
                style: AppText.body(12, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(controller.levelInChapter / AppConstants.levelsPerChapter),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Play',
            icon: Icons.play_arrow_rounded,
            height: 60,
            fontSize: 19,
            onPressed: controller.play,
          ),
        ],
      ),
    );
  });

  Widget _modes() => Row(
    children: [
      Expanded(
        child: AppCard(
          onTap: () => Get.toNamed(Routes.daily),
          padding: const EdgeInsets.all(14),
          child: Obx(() {
            final streak = controller.progress.dailyStreak;
            final done = controller.dailyDoneToday;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(Icons.calendar_month_rounded, color: AppColors.violet, size: 40),
                    const Spacer(),
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.ember, size: 16),
                    Text(
                      '$streak',
                      style: AppText.body(13, weight: FontWeight.w700, color: AppColors.ember),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Daily Challenge', style: AppText.display(15)),
                const SizedBox(height: 3),
                Text(
                  '${Fmt.friendlyDate(Fmt.today())} · ${done ? 'Solved' : 'New'}',
                  style: AppText.muted(12),
                ),
              ],
            );
          }),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: AppCard(
          onTap: controller.openQuickPlay,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconBadge(Icons.bolt_rounded, color: AppColors.mint, size: 40),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                    child: Text('5 modes', style: AppText.muted(11, weight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Quick Play', style: AppText.display(15)),
              const SizedBox(height: 3),
              Text('Pick a difficulty', style: AppText.muted(12)),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _promo() => Obx(() {
    if (controller.showStarterOffer) {
      return _promoCard(
        title: 'Starter Pack · −40%',
        subtitle: 'No ads + 30 hints · ends in ${controller.offerCountdown.value}',
        price: controller.iap.price(IapIds.starterPack),
      );
    }
    if (controller.showRemoveAdsPromo) {
      return _promoCard(
        title: 'Remove Ads forever',
        subtitle: 'One-time purchase · no banners or pop-ups',
        price: controller.iap.price(IapIds.removeAds),
      );
    }
    return const SizedBox.shrink();
  });

  Widget _promoCard({required String title, required String subtitle, required String price}) => AppCard(
    onTap: () => Get.toNamed(Routes.store),
    color: AppColors.vipSurface,
    borderColor: AppColors.vipLine,
    radius: 20,
    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
    child: Row(
      children: [
        const IconBadge(Icons.card_giftcard_rounded, color: AppColors.violet, size: 40, filled: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.body(14, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.body(12, color: AppColors.violetSoft)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
          child: Text(
            price,
            style: AppText.body(13, weight: FontWeight.w800, color: AppColors.onGold),
          ),
        ),
      ],
    ),
  );

  Widget _nav() {
    Widget item(IconData icon, String label, String? route, {bool active = false}) => Expanded(
      child: InkWell(
        onTap: route == null ? null : () => Get.toNamed(route),
        child: Semantics(
          selected: active,
          button: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 23, color: active ? AppColors.gold : AppColors.muted),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppText.body(
                  11,
                  weight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? AppColors.gold : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border(top: BorderSide(color: AppColors.lineSoft)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              item(Icons.home_rounded, 'Home', null, active: true),
              item(Icons.grid_view_rounded, 'Levels', Routes.levelMap),
              item(Icons.calendar_month_rounded, 'Daily', Routes.daily),
              item(Icons.emoji_events_rounded, 'Awards', Routes.achievements),
              item(Icons.bar_chart_rounded, 'Stats', Routes.stats),
            ],
          ),
        ),
      ),
    );
  }
}
