import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/difficulty.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/utils/formatters.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/ad_widgets.dart';
import '../../widgets/buttons.dart';
import 'game_controller.dart';
import 'widgets/board_view.dart';
import 'widgets/tray_view.dart';

class GameView extends GetView<GameController> {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.leave();
      },
      child: Obx(() {
        final theme = controller.theme;
        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(theme.isLight),
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                    }
                    return Column(
                      children: [
                        _infoRow(theme.isLight),
                        Expanded(
                          child: Obx(
                            () => AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: controller.paused.value ? 0.04 : 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: BoardView(controller: controller),
                              ),
                            ),
                          ),
                        ),
                        _toolbar(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                          child: TrayView(controller: controller),
                        ),
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
      }),
    );
  }

  Widget _header(bool light) {
    final fg = light ? const Color(0xFF1C1F2E) : AppColors.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Row(
        children: [
          IconSquareButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Back',
            size: 30,
            color: fg,
            onPressed: controller.leave,
          ),
          Expanded(
            child: Column(
              children: [
                Text(controller.title, style: AppText.display(19, color: fg)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: controller.difficulty.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    controller.subtitle,
                    style: AppText.label(
                      color: controller.difficulty.color,
                    ).copyWith(fontSize: 10, letterSpacing: 1.6),
                  ),
                ),
              ],
            ),
          ),
          IconSquareButton(
            icon: Icons.pause_rounded,
            tooltip: 'Pause',
            color: fg,
            onPressed: controller.pause,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(bool light) {
    final muted = light ? const Color(0xFF5A5F75) : AppColors.muted;
    final fg = light ? const Color(0xFF1C1F2E) : AppColors.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Obx(() {
        final limit = controller.mistakeLimit;
        return Row(
          children: [
            Text(
              'Mistakes',
              style: AppText.body(13, weight: FontWeight.w600, color: muted),
            ),
            const SizedBox(width: 8),
            if (limit > 0)
              for (var i = 0; i < limit; i++)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < controller.mistakes.value ? AppColors.coral : AppColors.line,
                  ),
                ),
            const SizedBox(width: 4),
            Text(
              limit > 0 ? '${controller.mistakes.value}/$limit' : '${controller.mistakes.value} · no limit',
              style: AppText.body(13, weight: FontWeight.w600, color: fg),
            ),
            const Spacer(),
            if (controller.settings.showTimer.value) ...[
              Icon(Icons.schedule_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Text(
                Fmt.time(controller.seconds.value),
                style: AppText.body(
                  13,
                  weight: FontWeight.w600,
                  color: fg,
                ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _toolbar() {
    Widget tool(IconData icon, String label, VoidCallback onTap, {Widget? badge, bool gold = false}) =>
        Semantics(
          button: true,
          label: label,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: gold ? AppColors.gold.withValues(alpha: 0.12) : AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: gold ? AppColors.gold.withValues(alpha: 0.5) : AppColors.line,
                          ),
                        ),
                        child: Icon(icon, size: 22, color: gold ? AppColors.gold : AppColors.muted),
                      ),
                      if (badge != null) Positioned(top: -6, right: -6, child: badge),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: AppText.body(
                      12,
                      weight: FontWeight.w600,
                      color: controller.theme.isLight ? const Color(0xFF1C1F2E) : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      child: Row(
        children: [
          Expanded(child: tool(Icons.undo_rounded, 'Undo', controller.undo)),
          Expanded(child: tool(Icons.backspace_outlined, 'Erase', controller.erase)),
          Expanded(
            child: Obx(() {
              final vip = PurchaseService.to.isVip;
              final n = ProgressService.to.hints.value;
              final badge = Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: n == 0 && !vip ? AppColors.violet : AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  vip ? '∞' : (n == 0 ? '+' : '$n'),
                  style: AppText.display(11, color: AppColors.onGold),
                ),
              );
              return tool(Icons.lightbulb_outline_rounded, 'Hint', controller.hint, badge: badge, gold: true);
            }),
          ),
        ],
      ),
    );
  }
}
