import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/models/achievement.dart';
import '../../data/services/progress_service.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'achievements_controller.dart';

/// Artboard 23 — Awards.
class AchievementsView extends GetView<AchievementsController> {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final p = controller.progress;
          p.achievementsClaimed.length;
          p.statsVersion.value;
          return Column(
            children: [
              AppHeader(
                title: 'Awards',
                actions: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${p.achievementsUnlockedCount}',
                          style: AppText.body(13, weight: FontWeight.w700, color: AppColors.gold),
                        ),
                        TextSpan(
                          text: ' / ${AchievementDef.all.length}',
                          style: AppText.muted(13, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: AchievementDef.all.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _tile(AchievementDef.all[i], p),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _tile(AchievementDef a, ProgressService p) {
    final value = p.metric(a.metric);
    final done = value >= a.target;
    final claimed = p.achievementsClaimed.contains(a.id);
    final pct = (value / a.target).clamp(0.0, 1.0);
    return AppCard(
      radius: 20,
      borderColor: done && !claimed ? AppColors.gold : AppColors.line,
      borderWidth: done && !claimed ? 1.5 : 1,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: done ? AppColors.gold : AppColors.surface2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(a.icon, color: done ? AppColors.onGold : AppColors.dim),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: AppText.display(15)),
                const SizedBox(height: 2),
                Text(a.description, style: AppText.muted(12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ProgressBar(pct, height: 6, color: done ? AppColors.mint : AppColors.violet),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${value.clamp(0, a.target)}/${a.target}',
                      style: AppText.muted(11, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (done && !claimed)
            PrimaryButton(
              label: '+${a.reward}',
              icon: Icons.lightbulb_outline_rounded,
              expand: false,
              height: 40,
              fontSize: 13,
              onPressed: () => controller.claim(a),
            )
          else if (claimed)
            Text(
              'Claimed',
              style: AppText.body(12, weight: FontWeight.w700, color: AppColors.mint),
            )
          else
            Text(
              '+${a.reward} hints',
              style: AppText.body(12, weight: FontWeight.w700, color: AppColors.gold),
            ),
        ],
      ),
    );
  }
}
