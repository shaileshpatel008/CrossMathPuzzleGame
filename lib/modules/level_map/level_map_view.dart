import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/models/difficulty.dart';
import '../../data/services/progress_service.dart';
import '../../widgets/ad_widgets.dart';
import '../../widgets/common.dart';
import 'level_map_controller.dart';

/// Artboard 07 — Level map (journey with chapters).
class LevelMapView extends GetView<LevelMapController> {
  const LevelMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Journey',
              actions: [
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.gold, size: 15),
                        const SizedBox(width: 5),
                        Text(
                          '${controller.progress.totalStars} / ${controller.progress.maxStars}',
                          style: AppText.body(13, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                final cur = controller.currentChapter;
                controller.progress.levelStars.length;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  children: [
                    _tiers(),
                    const SizedBox(height: 12),
                    _lockedChapter(cur + 1),
                    const SizedBox(height: 12),
                    for (var ch = cur; ch >= 1; ch--) ...[_chapter(ch, cur), const SizedBox(height: 12)],
                  ],
                );
              }),
            ),
            const BannerAdView(),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _tiers() {
    final level = controller.progress.currentLevel.value;
    const tiers = [Difficulty.easy, Difficulty.medium, Difficulty.hard, Difficulty.expert, Difficulty.master];
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          for (final t in tiers)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: [
                    ProgressBar(
                      ((level - t.firstLevel) / (t.lastLevel - t.firstLevel + 1)).clamp(0.0, 1.0),
                      color: level > t.lastLevel ? AppColors.mint : AppColors.gold,
                      height: 6,
                      track: AppColors.line,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.label,
                      style: AppText.body(
                        11,
                        weight: FontWeight.w700,
                        color: level > t.lastLevel
                            ? AppColors.mint
                            : (level >= t.firstLevel ? AppColors.gold : AppColors.dim),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chapter(int ch, int current) {
    final start = ProgressService.chapterStart(ch);
    final end = start + AppConstants.levelsPerChapter - 1;
    final tier = DifficultyX.forLevel(start);
    final done = ch < current;
    final isOpen = controller.expanded.contains(ch);
    final stars = controller.progress.starsInChapter(ch);
    final levelNow = controller.progress.currentLevel.value;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      borderColor: ch == current ? AppColors.gold.withValues(alpha: 0.45) : AppColors.line,
      borderWidth: ch == current ? 1.5 : 1,
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.toggle(ch),
            child: Row(
              children: [
                if (done) ...[
                  const IconBadge(Icons.check_rounded, color: AppColors.mint, size: 36),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chapter $ch · ${tier.label}', style: AppText.display(16)),
                      const SizedBox(height: 2),
                      Text(
                        done
                            ? 'Levels $start–$end · $stars / 60 stars'
                            : '${levelNow - start} / 20 · $stars stars',
                        style: AppText.muted(12),
                      ),
                    ],
                  ),
                ),
                Icon(isOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppColors.muted),
              ],
            ),
          ),
          if (isOpen) ...[
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 1,
              children: [for (var l = start; l <= end; l++) _levelTile(l, levelNow)],
            ),
          ],
        ],
      ),
    );
  }

  Widget _levelTile(int l, int current) {
    final stars = controller.progress.levelStars[l] ?? 0;
    if (l > current) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLow,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.lineSoft),
        ),
        child: Semantics(
          label: 'Level $l, locked',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 14, color: AppColors.disabled),
              Text('$l', style: AppText.display(13, color: AppColors.dim)),
            ],
          ),
        ),
      );
    }
    final isCurrent = l == current;
    return Material(
      color: isCurrent ? AppColors.gold : AppColors.surface2,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => controller.openLevel(l),
        child: Semantics(
          button: true,
          label: 'Level $l${isCurrent ? ', play' : ', $stars stars'}',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$l', style: AppText.display(16, color: isCurrent ? AppColors.onGold : AppColors.text)),
              const SizedBox(height: 3),
              if (isCurrent)
                Text(
                  'PLAY',
                  style: AppText.body(10, weight: FontWeight.w800, color: AppColors.onGold),
                )
              else
                StarRow(stars, size: 11),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lockedChapter(int ch) {
    final start = ProgressService.chapterStart(ch);
    return AppCard(
      color: AppColors.surfaceLow,
      borderColor: AppColors.lineSoft,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const IconBadge(Icons.lock_rounded, color: AppColors.muted, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter $ch · Levels $start–${start + 19}',
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text('Finish Chapter ${ch - 1} to unlock', style: AppText.muted(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
