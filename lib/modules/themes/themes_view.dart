import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../app/theme/game_themes.dart';
import '../../data/models/difficulty.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import 'themes_controller.dart';

/// Artboard 24 — Themes with live preview.
class ThemesView extends GetView<ThemesController> {
  const ThemesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final t = controller.previewTheme;
          final applied = controller.settings.themeId.value == t.id;
          final locked = !controller.unlocked(t);
          return Column(
            children: [
              const AppHeader(title: 'Themes'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    _preview(t),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.72,
                      children: [for (final g in GameTheme.all) _swatch(g)],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('Number size', style: AppText.body(14, weight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              for (var i = 0; i < 3; i++)
                                Semantics(
                                  selected: controller.settings.numberSize.value == i,
                                  button: true,
                                  label: 'Number size ${['small', 'medium', 'large'][i]}',
                                  child: GestureDetector(
                                    onTap: () => controller.settings.numberSize.value = i,
                                    child: Container(
                                      width: 44,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: controller.settings.numberSize.value == i
                                            ? AppColors.gold
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Text(
                                        ['S', 'M', 'L'][i],
                                        style: AppText.display(
                                          13,
                                          color: controller.settings.numberSize.value == i
                                              ? AppColors.onGold
                                              : AppColors.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: PrimaryButton(
                  label: applied
                      ? 'Applied'
                      : locked
                      ? (t.unlock == ThemeUnlock.vip ? 'Unlock with VIP' : 'How to unlock')
                      : 'Apply ${t.name}',
                  icon: locked ? Icons.lock_open_rounded : null,
                  tone: locked && t.unlock == ThemeUnlock.vip ? ButtonTone.violet : ButtonTone.gold,
                  onPressed: applied ? null : controller.apply,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _preview(GameTheme t) {
    const rows = [
      ['8', Ops.sub, '', '=', '5'],
      [Ops.div, ' ', Ops.add, ' ', Ops.add],
      ['2', Ops.add, '4', '=', '6'],
      ['=', ' ', '=', ' ', '='],
      ['4', Ops.add, '7', '=', '11'],
    ];
    final scale = controller.settings.numberScale;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in r)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: int.tryParse(c) != null ? t.cell : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: c.isEmpty ? Border.all(color: t.accent, width: 2) : null,
                      ),
                      child: Text(
                        c.trim(),
                        style: AppText.display(
                          15 * scale,
                          weight: FontWeight.w700,
                          color: int.tryParse(c) != null ? t.cellText : t.op,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final v in [3, 9, 12])
                Container(
                  width: 52,
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.accent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: t.accentShadow, offset: const Offset(0, 4))],
                  ),
                  child: Text('$v', style: AppText.display(19, color: t.tileText)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swatch(GameTheme g) {
    final selected = controller.preview.value == g.id;
    final inUse = controller.settings.themeId.value == g.id;
    final unlocked = controller.unlocked(g);
    final tag = inUse
        ? 'IN USE'
        : (unlocked ? (g.unlock == ThemeUnlock.free ? 'FREE' : 'UNLOCKED') : g.unlockLabel);
    return Semantics(
      button: true,
      selected: selected,
      label: '${g.name} theme, $tag',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => controller.preview.value = g.id,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? AppColors.gold : AppColors.line, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: g.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: g.cell, borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: g.accent, borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(g.name, style: AppText.body(12, weight: FontWeight.w700)),
              Text(
                tag,
                style: AppText.body(
                  9,
                  weight: FontWeight.w800,
                  color: inUse
                      ? AppColors.mint
                      : (g.unlock == ThemeUnlock.vip && !unlocked ? AppColors.violetSoft : AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
