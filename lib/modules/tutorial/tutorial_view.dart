import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/models/puzzle.dart';
import '../../widgets/buttons.dart';
import 'tutorial_controller.dart';

class TutorialView extends GetView<TutorialController> {
  const TutorialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final step = controller.step.value;
          return Column(
            children: [
              const SizedBox(height: 20),
              Text('Level 1', style: AppText.display(20)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('TUTORIAL', style: AppText.label(color: AppColors.mint).copyWith(fontSize: 10)),
              ),
              const SizedBox(height: 20),
              _board(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
                  decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.onGold),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.tipTitle,
                              style: AppText.display(15, color: const Color(0xFF151A3A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.tip,
                              style: AppText.body(14, color: const Color(0xFF3C4268), height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(key: ValueKey('tip$step')).fadeIn(duration: 300.ms).moveY(begin: 8, end: 0),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [for (final v in TutorialController.answers) _tile(v, step)],
              ),
              const Spacer(),
              if (step >= 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: PrimaryButton(
                    label: "You're ready · Let's play",
                    tone: ButtonTone.mint,
                    onPressed: controller.finish,
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextLinkButton('Skip tutorial', onPressed: controller.skip),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _board() {
    final p = controller.puzzle;
    final focus = controller.focus;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.lineSoft),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < 5; r++)
            Padding(
              padding: EdgeInsets.only(bottom: r < 4 ? 7 : 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 5; c++)
                    Padding(
                      padding: EdgeInsets.only(right: c < 4 ? 7 : 0),
                      child: Opacity(
                        opacity: focus.isEmpty || focus.contains(r * 5 + c) ? 1 : 0.28,
                        child: _cell(p, r * 5 + c),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(Puzzle p, int i) {
    const s = 52.0;
    final cell = p.cells[i];
    final step = controller.step.value;
    final isTarget = TutorialController.targets.indexOf(i);
    if (isTarget >= 0 && !controller.isFilled(i)) {
      final active = isTarget == step;
      final box = Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: active ? AppColors.gold.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: active ? AppColors.gold : AppColors.lineDashed, width: active ? 2.5 : 2),
          boxShadow: active
              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.18), spreadRadius: 6)]
              : null,
        ),
      );
      return active
          ? box.animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.06, duration: 700.ms)
          : box;
    }
    if (isTarget >= 0) {
      return Container(
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mint.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.mint.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Text(
          cell.text,
          style: AppText.display(21, weight: FontWeight.w700, color: AppColors.mint),
        ),
      ).animate().scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack);
    }
    if (cell.kind == CellKind.empty) return const SizedBox(width: s, height: s);
    final isNum = cell.isNumber;
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isNum ? AppColors.surface2 : const Color(0xFF141B42),
        borderRadius: BorderRadius.circular(13),
        border: isNum ? Border.all(color: AppColors.line) : null,
      ),
      child: Text(
        cell.text,
        style: AppText.display(
          21,
          weight: FontWeight.w700,
          color: isNum ? AppColors.text : (cell.kind == CellKind.equals ? AppColors.muted : AppColors.violet),
        ),
      ),
    );
  }

  Widget _tile(int v, int step) {
    final used = controller.tileUsed(v);
    final want = step < 2 && TutorialController.answers[step] == v;
    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: used ? AppColors.surface2 : AppColors.gold.withValues(alpha: want ? 1 : 0.5),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: used ? null : () => controller.tapTile(v),
          child: Container(
            width: 72,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: want
                  ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.22), spreadRadius: 6)]
                  : null,
            ),
            child: Text(
              '$v',
              style: AppText.display(26, color: used ? AppColors.disabled : AppColors.onGold),
            ),
          ),
        ),
      ),
    );
    return Obx(
      () => tile
          .animate(key: ValueKey('w${controller.wrongTap.value}$v'))
          .shakeX(duration: want ? 1.ms : 300.ms, hz: 5, amount: want ? 0 : 3),
    );
  }
}
