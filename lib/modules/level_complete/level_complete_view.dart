import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../data/models/difficulty.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../data/services/progress_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/decorations.dart';
import 'level_complete_controller.dart';

/// Artboard 15 — Level complete.
class LevelCompleteView extends GetView<LevelCompleteController> {
  const LevelCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = controller.result;
    final nextLabel = controller.isJourney
        ? 'Next · Level ${ProgressService.to.currentLevel.value}'
        : 'Next puzzle';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.home();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: SymbolConfetti()),
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 56),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < 3; i++)
                                Transform.rotate(
                                  angle: i == 0 ? -0.24 : (i == 2 ? 0.24 : 0),
                                  child:
                                      Icon(
                                            Icons.star_rounded,
                                            size: i == 1 ? 96 : 66,
                                            color: i < r.stars ? AppColors.gold : AppColors.line,
                                            shadows: i < r.stars
                                                ? [
                                                    Shadow(
                                                      color: AppColors.gold.withValues(alpha: 0.55),
                                                      blurRadius: 24,
                                                    ),
                                                  ]
                                                : null,
                                          )
                                          .animate(delay: (250 + i * 220).ms)
                                          .scale(
                                            begin: const Offset(0, 0),
                                            curve: Curves.easeOutBack,
                                            duration: 450.ms,
                                          ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            controller.headline,
                            style: AppText.label(
                              color: AppColors.mint,
                            ).copyWith(fontSize: 13, letterSpacing: 2),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.isJourney
                                ? 'Level ${controller.args.level} complete'
                                : '${controller.args.difficulty.label} solved',
                            textAlign: TextAlign.center,
                            style: AppText.display(32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r.stars == 3
                                ? 'Flawless — no mistakes, no hints'
                                : 'Solve with no mistakes and no hints for 3 stars',
                            style: AppText.muted(13),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                  label: 'Time',
                                  value: Fmt.time(r.seconds),
                                  caption: r.newBest ? 'New best' : null,
                                  valueColor: AppColors.text,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatTile(
                                  label: 'Mistakes',
                                  value: '${r.mistakes}',
                                  valueColor: r.mistakes == 0 ? AppColors.mint : AppColors.coral,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: StatTile(label: 'Hints', value: '${r.hintsUsed}', caption: 'used'),
                              ),
                            ],
                          ),
                          if (r.chapterCompleted) ...[
                            const SizedBox(height: 12),
                            AppCard(
                              color: AppColors.mint.withValues(alpha: 0.10),
                              borderColor: AppColors.mint.withValues(alpha: 0.45),
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_rounded, color: AppColors.mint),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Chapter complete! +3 bonus hints',
                                      style: AppText.body(14, weight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (r.rewardHints > 0) ...[
                            const SizedBox(height: 12),
                            AppCard(
                              color: AppColors.gold.withValues(alpha: 0.08),
                              borderColor: AppColors.gold.withValues(alpha: 0.45),
                              borderWidth: 1.5,
                              radius: 20,
                              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                              child: Obx(
                                () => Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline_rounded,
                                      color: AppColors.gold,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            controller.bonusClaimed.value
                                                ? '+${r.rewardHints * 3} hints earned'
                                                : '+${r.rewardHints} hint${r.rewardHints == 1 ? '' : 's'} earned',
                                            style: AppText.display(15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            controller.bonusClaimed.value
                                                ? 'Bonus claimed'
                                                : 'Triple it with a short video',
                                            style: AppText.muted(12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!controller.bonusClaimed.value)
                                      PrimaryButton(
                                        label: '×3',
                                        icon: Icons.smart_display_rounded,
                                        tone: ButtonTone.mint,
                                        expand: false,
                                        height: 44,
                                        fontSize: 14,
                                        onPressed: controller.claimBonus,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        PrimaryButton(
                          label: nextLabel,
                          height: 60,
                          fontSize: 18,
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: controller.next,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: r.stars < 3 ? 'Replay for 3★' : 'Replay',
                                onPressed: controller.replay,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SecondaryButton(label: 'Home', onPressed: controller.home),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
