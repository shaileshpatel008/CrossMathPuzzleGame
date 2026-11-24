import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../data/models/difficulty.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/decorations.dart';
import 'daily_complete_controller.dart';

/// Artboard 10 — Daily complete & trophy cabinet.
class DailyCompleteView extends GetView<DailyCompleteController> {
  const DailyCompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    final r = controller.result;
    final date = r?.args.date ?? Fmt.today();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.backToCalendar();
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              if (r != null) const Positioned.fill(child: SymbolConfetti()),
              Column(
                children: [
                  if (r == null) const AppHeader(title: 'Trophy cabinet'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SizedBox(height: r == null ? 12 : 36),
                          Glow(
                            color: AppColors.violet,
                            child: Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                color: AppColors.violet,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  const BoxShadow(color: AppColors.violetShadow, offset: Offset(0, 10)),
                                  BoxShadow(
                                    color: AppColors.violet.withValues(alpha: 0.18),
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Fmt.monthsShort[date.month - 1].toUpperCase(),
                                    style: AppText.label(color: AppColors.bg).copyWith(letterSpacing: 2),
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: AppText.display(54, color: AppColors.bg, height: 1),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().scale(
                            begin: const Offset(0.5, 0.5),
                            curve: Curves.easeOutBack,
                            duration: 600.ms,
                          ),
                          const SizedBox(height: 18),
                          Text(r == null ? 'Your trophies' : 'Daily solved!', style: AppText.display(28)),
                          const SizedBox(height: 6),
                          if (r != null)
                            Text(
                              '${r.args.difficulty.label} · ${r.hintsUsed == 0 ? 'no hints used' : '${r.hintsUsed} hints used'}',
                              style: AppText.muted(14),
                            ),
                          const SizedBox(height: 22),
                          if (r != null)
                            Row(
                              children: [
                                Expanded(
                                  child: StatTile(label: 'Time', value: Fmt.time(r.seconds)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatTile(
                                    label: 'Streak',
                                    value: '${r.dailyStreak}',
                                    valueColor: AppColors.ember,
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
                              ],
                            ),
                          const SizedBox(height: 14),
                          _cabinet(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: [
                        PrimaryButton(label: 'Back to calendar', onPressed: controller.backToCalendar),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          label: 'Share my result',
                          icon: Icons.share_rounded,
                          onPressed: controller.share,
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

  Widget _cabinet() {
    final today = Fmt.today();
    final months = [for (var i = 3; i >= 0; i--) DateTime(today.year, today.month - i + 1)];
    final earned = controller.progress.trophiesEarned;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('Trophy cabinet', style: AppText.display(15)),
              const Spacer(),
              Text('$earned earned', style: AppText.muted(12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [for (final m in months) Expanded(child: _trophy(m, today))]),
        ],
      ),
    );
  }

  Widget _trophy(DateTime m, DateTime today) {
    final p = controller.progress;
    final future = m.isAfter(DateTime(today.year, today.month));
    final current = m.year == today.year && m.month == today.month;
    final got = !future && p.trophyEarned(m.year, m.month);
    final count = p.solvedInMonth(m.year, m.month);
    final (Color bg, Color fg, String label, Color labelColor) = future
        ? (AppColors.surfaceLow, AppColors.lineDashed, 'Locked', AppColors.dim)
        : got
        ? (AppColors.gold, AppColors.onGold, 'Gold', AppColors.gold)
        : current
        ? (
            AppColors.violet.withValues(alpha: 0.18),
            AppColors.violet,
            '$count / ${AppConstants.monthlyTrophyTarget}',
            AppColors.violetSoft,
          )
        : (AppColors.surface2, AppColors.dim, 'Missed', AppColors.dim);
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: current && !got ? Border.all(color: AppColors.violet, width: 1.5) : null,
            boxShadow: got ? const [BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 4))] : null,
          ),
          child: Icon(Icons.emoji_events_rounded, color: fg, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          Fmt.monthsShort[m.month - 1],
          style: AppText.body(11, weight: FontWeight.w700, color: AppColors.muted),
        ),
        Text(
          label,
          style: AppText.body(10, weight: FontWeight.w700, color: labelColor),
        ),
      ],
    );
  }
}
