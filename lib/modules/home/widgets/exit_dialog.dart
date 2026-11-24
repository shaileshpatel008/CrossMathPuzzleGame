import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/utils/formatters.dart';
import '../../../data/services/progress_service.dart';
import '../../../widgets/ad_widgets.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/dialogs.dart';

/// Artboard 27 — "Leaving already?" with a native ad (hidden for Remove Ads / VIP).
class ExitDialog extends StatelessWidget {
  const ExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final p = ProgressService.to;
    final dailyDone = p.isDailySolved(Fmt.today());
    final streak = p.dailyStreak;
    return AppDialog(
      children: [
        Text('Leaving already?', style: AppText.display(23)),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Your progress is saved. '),
              if (!dailyDone && streak > 0) ...[
                const TextSpan(text: "Today's daily challenge is still waiting — and your "),
                TextSpan(
                  text: '$streak-day streak',
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.ember),
                ),
                const TextSpan(text: ' ends at midnight.'),
              ] else if (!dailyDone)
                const TextSpan(text: "Today's daily challenge is still waiting for you.")
              else
                const TextSpan(text: 'See you tomorrow for a fresh daily puzzle!'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppText.muted(14).copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        const NativeAdView(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(label: 'Exit', height: 54, onPressed: () => SystemNavigator.pop()),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: dailyDone ? 'Keep playing' : 'Play daily',
                height: 54,
                fontSize: 15,
                onPressed: () {
                  Get.back();
                  if (!dailyDone) Get.toNamed(Routes.daily);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
