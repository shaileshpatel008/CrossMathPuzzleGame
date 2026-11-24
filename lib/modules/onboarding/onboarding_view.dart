import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/models/difficulty.dart';
import '../../widgets/buttons.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
              child: Row(
                children: [
                  Obx(
                    () => Text(
                      '${controller.page.value + 1} of ${OnboardingController.pages}',
                      style: AppText.muted(13, weight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  TextLinkButton(controller.fromGame ? 'Close' : 'Skip', onPressed: controller.skip),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  _Page(
                    illustration: _EquationArt(left: '8', op: Ops.sub, right: '5', tile: '3'),
                    title: 'Every row and column is an equation',
                    body:
                        'Tap an empty cell, then tap a number from the tray. Solve the whole grid so every equation is true.',
                  ),
                  _Page(
                    illustration: _MistakesArt(),
                    title: 'Each tile is used once — watch your mistakes',
                    body:
                        'Wrong numbers turn red. Three mistakes and the level ends, but you can earn a second chance.',
                  ),
                  _Page(
                    illustration: _EquationArt(left: '2', op: Ops.add, right: '14', tile: '3', long: true),
                    title: 'Long equations: × and ÷ first',
                    body:
                        'In Expert and Master puzzles, multiply and divide before you add and subtract — just like real maths.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Row(
                children: [
                  Obx(
                    () => Row(
                      children: [
                        for (var i = 0; i < OnboardingController.pages; i++)
                          AnimatedContainer(
                            duration: 250.ms,
                            margin: const EdgeInsets.only(right: 6),
                            width: i == controller.page.value ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == controller.page.value ? AppColors.gold : AppColors.line,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => PrimaryButton(
                      expand: false,
                      height: 56,
                      label: controller.page.value == OnboardingController.pages - 1
                          ? (controller.fromGame ? 'Got it' : 'Try it')
                          : 'Next',
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: controller.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.illustration, required this.title, required this.body});
  final Widget illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.line),
            ),
            alignment: Alignment.center,
            child: illustration,
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(title, style: AppText.display(28, height: 1.15)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(body, style: AppText.muted(15).copyWith(height: 1.55)),
          ),
        ],
      ),
    );
  }
}

Widget _box(String t, {bool blank = false, bool op = false, double size = 50}) => Container(
  width: op ? size * 0.7 : size,
  height: size,
  margin: const EdgeInsets.symmetric(horizontal: 3),
  alignment: Alignment.center,
  decoration: op
      ? null
      : BoxDecoration(
          color: blank ? AppColors.gold.withValues(alpha: 0.08) : AppColors.surface2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: blank ? AppColors.gold : AppColors.line, width: blank ? 2 : 1),
        ),
  child: Text(
    t,
    style: AppText.display(
      size * 0.42,
      weight: FontWeight.w700,
      color: op ? (t == '=' ? AppColors.muted : AppColors.violet) : AppColors.text,
    ),
  ),
);

class _EquationArt extends StatelessWidget {
  const _EquationArt({
    required this.left,
    required this.op,
    required this.right,
    required this.tile,
    this.long = false,
  });
  final String left, op, right, tile;
  final bool long;

  @override
  Widget build(BuildContext context) {
    final s = long ? 38.0 : 50.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
              width: 62,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  const BoxShadow(color: AppColors.goldShadow, offset: Offset(0, 5)),
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Text(tile, style: AppText.display(26, color: AppColors.onGold)),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: 16, duration: 1200.ms, curve: Curves.easeInOut),
        const SizedBox(height: 34),
        FittedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: long
                ? [
                    _box(left, size: s),
                    _box(Ops.add, op: true, size: s),
                    _box('', blank: true, size: s),
                    _box(Ops.mul, op: true, size: s),
                    _box('4', size: s),
                    _box('=', op: true, size: s),
                    _box(right, size: s),
                  ]
                : [
                    _box(left, size: s),
                    _box(op, op: true, size: s),
                    _box('', blank: true, size: s),
                    _box('=', op: true, size: s),
                    _box(right, size: s),
                  ],
          ),
        ),
      ],
    );
  }
}

class _MistakesArt extends StatelessWidget {
  const _MistakesArt();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final v in ['1', '4', '6', '6', '9'])
              Container(
                width: 46,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == '6' ? AppColors.surface2 : AppColors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  v,
                  style: AppText.display(20, color: v == '6' ? AppColors.disabled : AppColors.onGold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: 52,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: i == 0 ? AppColors.coral.withValues(alpha: 0.16) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: i == 0 ? AppColors.coral : AppColors.line, width: 1.5),
                ),
                child: Icon(Icons.close_rounded, color: i == 0 ? AppColors.coral : AppColors.line, size: 26),
              ),
          ],
        ),
      ],
    );
  }
}
