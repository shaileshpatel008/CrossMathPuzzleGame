import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../widgets/common.dart';
import '../../widgets/decorations.dart';
import 'splash_controller.dart';

/// Artboard 01 — Splash.
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  static const _floaters = [
    ('+', 0.10, 0.11, 44.0, AppColors.violet, -0.2),
    ('×', 0.78, 0.15, 52.0, AppColors.mint, 0.17),
    ('÷', 0.18, 0.62, 40.0, AppColors.coral, 0.14),
    ('=', 0.82, 0.56, 46.0, AppColors.gold, -0.1),
    ('7', 0.64, 0.07, 36.0, AppColors.text, 0.24),
    ('−', 0.08, 0.83, 50.0, AppColors.sky, 0.0),
    ('12', 0.74, 0.82, 34.0, AppColors.violet, -0.17),
    ('9', 0.10, 0.39, 38.0, AppColors.mint, -0.24),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DotBackground(
        child: LayoutBuilder(
          builder: (context, box) {
            return Stack(
              children: [
                for (final f in _floaters)
                  Positioned(
                    left: f.$2 * box.maxWidth,
                    top: f.$3 * box.maxHeight,
                    child:
                        Transform.rotate(
                              angle: f.$6,
                              child: Text(
                                f.$1,
                                style: AppText.display(f.$4, color: f.$5.withValues(alpha: 0.22)),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(begin: 0, end: 10, duration: 2400.ms, curve: Curves.easeInOut),
                  ),
                SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        const Glow(size: 220, child: LogoMark(size: 116, angle: -0.14))
                            .animate()
                            .scale(begin: const Offset(0.6, 0.6), duration: 600.ms, curve: Curves.easeOutBack)
                            .fadeIn(),
                        const SizedBox(height: 18),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'CrossMath', style: AppText.display(34)),
                              TextSpan(
                                text: 'Puzzle',
                                style: AppText.display(34, color: AppColors.gold),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 250.ms).moveY(begin: 12, end: 0),
                        const SizedBox(height: 10),
                        Text(
                          'Train your brain, one equation at a time',
                          style: AppText.muted(15),
                        ).animate().fadeIn(delay: 450.ms),
                        const Spacer(flex: 4),
                        SizedBox(
                          width: 220,
                          child: Obx(
                            () => ProgressBar(
                              controller.progress.value,
                              color: AppColors.gold,
                              height: 6,
                              track: AppColors.surface2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Loading puzzles…', style: AppText.muted(12)),
                        const SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
