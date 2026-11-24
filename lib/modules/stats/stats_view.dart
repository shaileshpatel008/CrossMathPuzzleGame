import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../data/models/difficulty.dart';
import '../../widgets/common.dart';
import 'stats_controller.dart';

/// Artboard 22 — Statistics.
class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: Obx(() {
                controller.progress.statsVersion.value;
                final s = controller.current;
                final all = controller.tab.value == null;
                final winRate = s.started == 0
                    ? '—'
                    : '${(s.solved * 100 / s.started).clamp(0, 100).round()}%';
                final cards = <(String, String, Color?)>[
                  ('Puzzles solved', '${s.solved}', null),
                  ('Win rate', winRate, AppColors.mint),
                  ('Perfect (3★)', '${s.perfect}', AppColors.gold),
                  ('Best time', s.bestTime == 0 ? '—' : Fmt.time(s.bestTime), null),
                  ('Current streak', all ? '${controller.progress.dailyStreak} days' : '—', AppColors.ember),
                  ('Best streak', all ? '${controller.progress.bestDailyStreak} days' : '—', null),
                  ('Hints used', '${s.hintsUsed}', null),
                  ('Time played', Fmt.duration(s.seconds), null),
                ];
                final week = controller.progress.solvedLastDays(7);
                final maxV = week.fold<int>(1, (a, b) => b > a ? b : a);
                final today = Fmt.today();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final t in StatsController.tabs)
                          ChoiceChip(
                            label: Text(t?.label ?? 'All'),
                            selected: controller.tab.value == t,
                            onSelected: (_) => controller.tab.value = t,
                            labelStyle: AppText.body(
                              13,
                              weight: FontWeight.w700,
                              color: controller.tab.value == t ? AppColors.onGold : AppColors.muted,
                            ),
                            selectedColor: AppColors.gold,
                            backgroundColor: AppColors.surface,
                            showCheckmark: false,
                            side: BorderSide(
                              color: controller.tab.value == t ? AppColors.gold : AppColors.line,
                            ),
                            shape: const StadiumBorder(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.9,
                      children: [
                        for (final (k, v, c) in cards)
                          AppCard(
                            radius: 18,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k, style: AppText.muted(12, weight: FontWeight.w600)),
                                const Spacer(),
                                Text(v, style: AppText.display(22, color: c ?? AppColors.text)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Puzzles solved · last 7 days', style: AppText.display(15)),
                              const Spacer(),
                              Text('${week.fold<int>(0, (a, b) => a + b)} total', style: AppText.muted(12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 130,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                for (var i = 0; i < 7; i++)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${week[i]}',
                                            style: AppText.body(11, weight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            height: 4 + 96 * week[i] / maxV,
                                            decoration: BoxDecoration(
                                              color: i == 6 ? AppColors.gold : AppColors.violet,
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(6),
                                                bottom: Radius.circular(2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            Fmt.weekdaysShort[today.subtract(Duration(days: 6 - i)).weekday -
                                                1][0],
                                            style: AppText.body(
                                              11,
                                              weight: i == 6 ? FontWeight.w700 : FontWeight.w500,
                                              color: i == 6 ? AppColors.gold : AppColors.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}
