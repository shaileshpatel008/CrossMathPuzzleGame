import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/progress_service.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/dialogs.dart';

/// Artboard 05 — 7-day daily gift. Claim ×2 with a reward video.
class DailyGiftDialog extends StatelessWidget {
  const DailyGiftDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressService.to;
    final today = p.giftDayToday;
    final reward = p.giftReward(today);

    Widget day(int d) {
      final claimed = d < today;
      final isToday = d == today;
      return Container(
        height: 86,
        decoration: BoxDecoration(
          color: isToday ? AppColors.gold : (claimed ? AppColors.bg : AppColors.surface2),
          borderRadius: BorderRadius.circular(16),
          border: isToday ? null : Border.all(color: claimed ? AppColors.lineSoft : AppColors.line),
          boxShadow: isToday
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), spreadRadius: 4)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'DAY $d',
              style: AppText.label(
                color: isToday ? AppColors.onGold : (claimed ? AppColors.mint : AppColors.muted),
              ).copyWith(fontSize: 10, letterSpacing: 1),
            ),
            const SizedBox(height: 4),
            Icon(
              claimed ? Icons.check_rounded : Icons.lightbulb_outline_rounded,
              size: 22,
              color: isToday ? AppColors.onGold : (claimed ? AppColors.mint : AppColors.muted),
            ),
            const SizedBox(height: 3),
            Text(
              claimed ? 'Claimed' : '+${p.giftReward(d)}',
              style: AppText.display(
                13,
                color: isToday ? AppColors.onGold : (claimed ? AppColors.mint : AppColors.muted),
              ),
            ),
          ],
        ),
      );
    }

    return AppDialog(
      onClose: () => Get.back(),
      children: [
        Transform.rotate(
          angle: -0.1,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.violet,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [BoxShadow(color: AppColors.violetShadow, offset: Offset(0, 8))],
            ),
            child: const Icon(Icons.card_giftcard_rounded, size: 42, color: AppColors.bg),
          ),
        ),
        const SizedBox(height: 18),
        Text('Daily Gift', style: AppText.display(26)),
        const SizedBox(height: 6),
        Text('Come back every day for bigger rewards', style: AppText.muted(14)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
          children: [for (var d = 1; d <= 6; d++) day(d)],
        ),
        const SizedBox(height: 8),
        Container(
          height: 76,
          decoration: BoxDecoration(
            color: today == 7 ? AppColors.gold : AppColors.vipSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.vipLine, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 30,
                color: today == 7 ? AppColors.onGold : AppColors.violetSoft,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY 7',
                    style: AppText.label(
                      color: today == 7 ? AppColors.onGold : AppColors.violetSoft,
                    ).copyWith(fontSize: 10),
                  ),
                  Text(
                    '+5 hints + Ocean theme',
                    style: AppText.display(13, color: today == 7 ? AppColors.onGold : AppColors.text),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Claim ×2 · Watch video',
          icon: Icons.smart_display_rounded,
          fontSize: 16,
          onPressed: () async {
            final earned = await Dialogs.watchRewarded();
            if (!earned) return;
            p.claimGift(multiplier: 2);
            Get.back();
            Dialogs.toast('+${reward * 2} hints added');
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Claim +$reward hint${reward == 1 ? '' : 's'}',
          onPressed: () {
            p.claimGift();
            AudioService.to.play(Sfx.reward);
            Get.back();
            Dialogs.toast('+$reward hint${reward == 1 ? '' : 's'} added');
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Miss a day and the gift streak restarts at Day 1',
          textAlign: TextAlign.center,
          style: AppText.muted(12),
        ),
      ],
    );
  }
}
