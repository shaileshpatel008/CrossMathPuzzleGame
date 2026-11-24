import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/utils/formatters.dart';
import '../../../data/models/difficulty.dart';
import '../../../data/models/game_args.dart';
import '../../../data/services/progress_service.dart';
import '../../../data/services/purchase_service.dart';
import '../../../widgets/dialogs.dart';

/// Artboard 08 — Quick Play difficulty picker.
class QuickPlaySheet extends StatelessWidget {
  const QuickPlaySheet({super.key});

  static const modes = [
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
    Difficulty.master,
  ];

  @override
  Widget build(BuildContext context) {
    final p = ProgressService.to;
    final vip = PurchaseService.to.isVip;
    final level = p.currentLevel.value;

    return AppSheet(
      children: [
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Quick Play', style: AppText.display(24)),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Endless random puzzles. Doesn't affect your journey.", style: AppText.muted(14)),
        ),
        const SizedBox(height: 18),
        for (final d in modes) ...[_row(d, p, vip, level), const SizedBox(height: 10)],
      ],
    );
  }

  Widget _row(Difficulty d, ProgressService p, bool vip, int level) {
    final unlockLevel = switch (d) {
      Difficulty.expert => AppConstants.expertUnlockLevel,
      Difficulty.master => AppConstants.masterUnlockLevel,
      _ => 0,
    };
    final open = level >= unlockLevel || vip;
    final best = p.stats(d).bestTime;
    return Material(
      color: open ? AppColors.surface2 : AppColors.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: open ? AppColors.line : AppColors.lineDashed),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (open) {
            Get.back();
            Get.toNamed(Routes.game, arguments: GameArgs.quick(d));
          } else if (d == Difficulty.master) {
            Get.back();
            Get.toNamed(Routes.vip);
          } else {
            Dialogs.info(
              '${d.label} is locked',
              'Reach journey level $unlockLevel to unlock ${d.label} Quick Play — or get VIP to unlock every mode now.',
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: open ? d.color.withValues(alpha: 0.16) : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(d.gridLabel, style: AppText.display(13, color: open ? d.color : AppColors.dim)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.label, style: AppText.display(16)),
                    const SizedBox(height: 3),
                    Text(d.description, style: AppText.muted(12)),
                  ],
                ),
              ),
              if (open)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Best', style: AppText.muted(11)),
                    Text(best == 0 ? '—' : Fmt.time(best), style: AppText.display(14)),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: d == Difficulty.master
                        ? AppColors.violet.withValues(alpha: 0.18)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 13,
                        color: d == Difficulty.master ? AppColors.violetSoft : AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d == Difficulty.master ? 'VIP · LV $unlockLevel' : 'LEVEL $unlockLevel',
                        style: AppText.body(
                          11,
                          weight: FontWeight.w800,
                          color: d == Difficulty.master ? AppColors.violetSoft : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
