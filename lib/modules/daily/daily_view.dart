import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'daily_controller.dart';

class DailyView extends GetView<DailyController> {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          controller.progress.dailySolved.length;
          final m = controller.month.value;
          final solvedMonth = controller.progress.solvedInMonth(m.year, m.month);
          return Column(
            children: [
              AppHeader(
                title: 'Daily Challenge',
                actions: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.ember.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppColors.ember, size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.progress.dailyStreak} days',
                          style: AppText.body(13, weight: FontWeight.w800, color: AppColors.ember),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    children: [
                      AppCard(
                        color: AppColors.vipSurface,
                        borderColor: AppColors.vipLine,
                        onTap: () => Get.toNamed(Routes.dailyComplete, arguments: null),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.violet,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(color: AppColors.violetShadow, offset: Offset(0, 6)),
                                ],
                              ),
                              child: const Icon(Icons.emoji_events_rounded, color: AppColors.bg, size: 32),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${Fmt.months[m.month - 1]} Trophy', style: AppText.display(16)),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Solve ${AppConstants.monthlyTrophyTarget} dailies this month',
                                    style: AppText.body(12, color: AppColors.violetSoft),
                                  ),
                                  const SizedBox(height: 10),
                                  ProgressBar(
                                    solvedMonth / AppConstants.monthlyTrophyTarget,
                                    color: AppColors.violet,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$solvedMonth/${AppConstants.monthlyTrophyTarget}',
                              style: AppText.display(15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppCard(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconSquareButton(
                                  icon: Icons.chevron_left_rounded,
                                  tooltip: 'Previous month',
                                  color: controller.canGoBack ? AppColors.muted : AppColors.lineDashed,
                                  onPressed: controller.canGoBack ? controller.prevMonth : null,
                                ),
                                Expanded(
                                  child: Text(
                                    '${Fmt.months[m.month - 1]} ${m.year}',
                                    textAlign: TextAlign.center,
                                    style: AppText.display(17),
                                  ),
                                ),
                                IconSquareButton(
                                  icon: Icons.chevron_right_rounded,
                                  tooltip: 'Next month',
                                  color: controller.canGoForward ? AppColors.muted : AppColors.lineDashed,
                                  onPressed: controller.canGoForward ? controller.nextMonth : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            GridView.count(
                              crossAxisCount: 7,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 0.95,
                              children: [
                                for (final w in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                                  Center(
                                    child: Text(
                                      w,
                                      style: AppText.body(11, weight: FontWeight.w700, color: AppColors.dim),
                                    ),
                                  ),
                                for (final d in controller.days) _day(d),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _legend(AppColors.mint, 'Solved'),
                                _legend(AppColors.ember, 'Missed', dashed: true),
                                _legend(AppColors.gold, 'Selected'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), child: _cta()),
            ],
          );
        }),
      ),
    );
  }

  Widget _day(DateTime? d) {
    final s = controller.state(d);
    if (s == DayState.empty) return const SizedBox.shrink();
    final isSel = d == controller.selected.value;
    Color bg = Colors.transparent, fg = AppColors.text;
    Border? border;
    switch (s) {
      case DayState.future:
        fg = AppColors.lineDashed;
      case DayState.missed:
        fg = AppColors.ember;
        border = Border.all(color: AppColors.ember, width: 1.5);
      case DayState.today:
        bg = AppColors.surface2;
        fg = AppColors.gold;
        border = Border.all(color: AppColors.gold, width: 1.5);
      case DayState.solved:
        bg = AppColors.mint.withValues(alpha: 0.16);
        fg = AppColors.mint;
      default:
        break;
    }
    if (isSel) {
      bg = AppColors.gold;
      fg = AppColors.onGold;
      border = null;
    }
    return Semantics(
      button: true,
      selected: isSel,
      label: '${Fmt.friendlyDate(d!)}, ${s.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.select(d),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border),
          child: Text(
            '${d.day}',
            style: AppText.display(14, weight: FontWeight.w700, color: fg),
          ),
        ),
      ),
    );
  }

  Widget _legend(Color c, String label, {bool dashed = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dashed ? null : c,
            border: dashed ? Border.all(color: c, width: 1.5) : null,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppText.muted(11)),
      ],
    ),
  );

  Widget _cta() {
    final d = controller.selected.value;
    switch (controller.selectedState) {
      case DayState.missed:
        final unlocked = controller.missedUnlocked;
        return Column(
          children: [
            PrimaryButton(
              label: unlocked
                  ? 'Play ${Fmt.monthsShort[d.month - 1]} ${d.day}'
                  : 'Unlock ${Fmt.monthsShort[d.month - 1]} ${d.day} · Watch video',
              icon: unlocked ? Icons.play_arrow_rounded : Icons.smart_display_rounded,
              fontSize: 16,
              onPressed: controller.play,
            ),
            const SizedBox(height: 8),
            Text(
              PurchaseService.to.isVip
                  ? 'VIP: every missed day is free'
                  : 'VIP members replay any missed day free',
              style: AppText.muted(12),
            ),
          ],
        );
      case DayState.solved:
        return Column(
          children: [
            PrimaryButton(
              label: 'Replay ${Fmt.monthsShort[d.month - 1]} ${d.day}',
              icon: Icons.replay_rounded,
              onPressed: controller.play,
            ),
            const SizedBox(height: 8),
            Text(
              "Solved in ${Fmt.time(controller.progress.dailySolved[Fmt.dateKey(d)] ?? 0)} · replays don't count toward the trophy",
              textAlign: TextAlign.center,
              style: AppText.muted(12),
            ),
          ],
        );
      default:
        final sunday = d.weekday == DateTime.sunday;
        return Column(
          children: [
            PrimaryButton(
              label: "Play today's challenge",
              icon: Icons.play_arrow_rounded,
              onPressed: controller.play,
            ),
            const SizedBox(height: 8),
            Text(
              '${sunday ? 'Expert · 11×11' : 'Hard · 9×9'} · new puzzle every day at midnight',
              style: AppText.muted(12),
            ),
          ],
        );
    }
  }
}
