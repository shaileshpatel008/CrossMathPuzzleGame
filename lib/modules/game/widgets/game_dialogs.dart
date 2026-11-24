import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/difficulty.dart';

import '../../../app/constants/iap_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/utils/formatters.dart';
import '../../../data/services/ads_service.dart';
import '../../../data/services/progress_service.dart';
import '../../../data/services/purchase_service.dart';
import '../../../data/services/settings_service.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/common.dart';
import '../../../widgets/dialogs.dart';
import '../../purchase/purchase_flow_controller.dart';
import '../game_controller.dart';

/// Artboard 12 — Pause.
class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final s = SettingsService.to;
    final limit = controller.mistakeLimit;
    Widget toggle(RxBool v, IconData icon, String label) => Expanded(
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: v.value ? AppColors.gold.withValues(alpha: 0.12) : AppColors.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: v.value ? AppColors.gold.withValues(alpha: 0.6) : AppColors.lineSoft,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => v.toggle(),
              child: Semantics(
                toggled: v.value,
                label: label,
                child: SizedBox(
                  height: 66,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20, color: v.value ? AppColors.gold : AppColors.dim),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: AppText.body(
                          11,
                          weight: FontWeight.w600,
                          color: v.value ? AppColors.gold : AppColors.dim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: 'resume');
      },
      child: AppDialog(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.pause_rounded, color: AppColors.gold, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Paused', style: AppText.display(26)),
          const SizedBox(height: 6),
          Text('The board is hidden while the timer is stopped', style: AppText.muted(13)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _info(
                  controller.args.level != null ? 'Level' : 'Mode',
                  controller.args.level?.toString() ?? controller.difficulty.label,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _info('Time', Fmt.time(controller.seconds.value))),
              const SizedBox(width: 8),
              Expanded(
                child: _info(
                  'Mistakes',
                  limit == 0 ? '${controller.mistakes.value}' : '${controller.mistakes.value} / $limit',
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              toggle(s.sfx, Icons.volume_up_rounded, 'Sound'),
              toggle(s.music, Icons.music_note_rounded, 'Music'),
              toggle(s.vibration, Icons.vibration_rounded, 'Vibrate'),
              toggle(s.autoCheck, Icons.check_rounded, 'Auto-check'),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Resume',
            icon: Icons.play_arrow_rounded,
            onPressed: () => Get.back(result: 'resume'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Restart',
                  icon: Icons.replay_rounded,
                  onPressed: () async {
                    final ok = await Dialogs.confirm(
                      title: 'Restart level?',
                      message: 'Your current board, time and mistakes will be cleared.',
                      confirmLabel: 'Restart',
                    );
                    if (ok) Get.back(result: 'restart');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: 'Home',
                  icon: Icons.home_rounded,
                  onPressed: () => Get.back(result: 'home'),
                ),
              ),
            ],
          ),
          TextLinkButton(
            'How to play',
            color: AppColors.gold,
            onPressed: () => Get.back(result: 'howto'),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {Color color = AppColors.text}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
    child: Column(
      children: [
        Text(label, style: AppText.muted(11)),
        const SizedBox(height: 3),
        Text(value, style: AppText.display(15, color: color)),
      ],
    ),
  );
}

/// Artboard 14 — Out of mistakes (second chance).
class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final p = controller.p;
    final placedRight = p.blanks.where(controller.isCorrect).length;
    final left = p.blanks.length - placedRight;
    final canContinue = !controller.secondChanceUsed;
    final vip = controller.isVip;
    return PopScope(
      canPop: false,
      child: AppDialog(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final a in [-0.14, 0.0, 0.14])
                Transform.rotate(
                  angle: a,
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.coral, width: 1.5),
                    ),
                    child: const Icon(Icons.close_rounded, color: AppColors.coral, size: 28),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Out of mistakes', style: AppText.display(26)),
          const SizedBox(height: 8),
          Text(
            'You were $left number${left == 1 ? '' : 's'} away from solving ${controller.title}. Keep your progress and try again?',
            textAlign: TextAlign.center,
            style: AppText.muted(14).copyWith(height: 1.5),
          ),
          const SizedBox(height: 18),
          ProgressBar(placedRight / p.blanks.length, height: 10),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Board progress', style: AppText.muted(12)),
              const Spacer(),
              Text(
                '$placedRight / ${p.blanks.length} placed',
                style: AppText.body(12, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (canContinue) ...[
            PrimaryButton(
              label: vip ? 'Continue · VIP' : 'Second chance · Watch video',
              icon: vip ? Icons.workspace_premium_rounded : Icons.smart_display_rounded,
              fontSize: 16,
              height: 60,
              onPressed: controller.useSecondChance,
            ),
            const SizedBox(height: 8),
            Text('Removes your last mistake · once per level', style: AppText.muted(12)),
            if (!vip) ...[
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'VIP: continue instantly, no ads',
                icon: Icons.workspace_premium_rounded,
                background: AppColors.vipSurface,
                borderColor: AppColors.vipLine,
                onPressed: () => Get.toNamed(Routes.vip),
              ),
            ],
          ] else
            Text('Second chance already used on this level.', style: AppText.muted(13)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Restart level',
                  onPressed: () => Get.back(result: 'restart'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: 'Home',
                  onPressed: () => Get.back(result: 'home'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Artboard 13 — Out of hints.
class OutOfHintsSheet extends StatelessWidget {
  const OutOfHintsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final iap = PurchaseService.to;
    final ads = AdsService.to;
    final left = ads.rewardedHintsLeftToday;
    Widget pack(String id, int n, String? tag) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            AppCard(
              color: AppColors.surface2,
              borderColor: tag == 'POPULAR' ? AppColors.violet : AppColors.line,
              borderWidth: tag == 'POPULAR' ? 1.5 : 1,
              radius: 18,
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 12),
              onTap: () => PurchaseFlowController.to.buy(id),
              child: Column(
                children: [
                  Text('$n', style: AppText.display(24, color: AppColors.gold)),
                  Text('hints', style: AppText.muted(12)),
                  const SizedBox(height: 8),
                  Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(11)),
                    child: Obx(
                      () => Text(
                        iap.price(id),
                        style: AppText.body(14, weight: FontWeight.w800, color: AppColors.onGold),
                      ),
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

    return AppSheet(
      children: [
        const SizedBox(height: 18),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 7))],
          ),
          child: const Icon(Icons.lightbulb_outline_rounded, size: 34, color: AppColors.onGold),
        ),
        const SizedBox(height: 18),
        Text('Out of hints', style: AppText.display(24)),
        const SizedBox(height: 6),
        Text('A hint places one correct number for you', style: AppText.muted(14)),
        const SizedBox(height: 20),
        AppCard(
          color: AppColors.mint.withValues(alpha: 0.10),
          borderColor: AppColors.mint.withValues(alpha: 0.5),
          borderWidth: 1.5,
          radius: 18,
          padding: const EdgeInsets.all(14),
          onTap: left <= 0
              ? null
              : () async {
                  final earned = await Dialogs.watchRewarded();
                  if (!earned) return;
                  ProgressService.to.addHints(1);
                  ads.noteRewardedHint();
                  Get.back();
                  Dialogs.toast('+1 hint added');
                },
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
                      left > 0 ? '+1 hint · $left of 5 left today' : 'Come back tomorrow for more',
                      style: AppText.muted(12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'FREE',
                  style: AppText.body(13, weight: FontWeight.w800, color: AppColors.onMint),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            pack(IapIds.hints10, 10, null),
            pack(IapIds.hints50, 50, 'POPULAR'),
            pack(IapIds.hints150, 150, 'BEST VALUE'),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.vipSurface,
          borderColor: AppColors.vipLine,
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () {
            Get.back();
            Get.toNamed(Routes.vip);
          },
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.violet),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Unlimited hints with VIP', style: AppText.body(14, weight: FontWeight.w700)),
              ),
              Text(
                'Try free →',
                style: AppText.body(13, weight: FontWeight.w700, color: AppColors.violetSoft),
              ),
            ],
          ),
        ),
        TextLinkButton('Not now', onPressed: () => Get.back()),
      ],
    );
  }
}
