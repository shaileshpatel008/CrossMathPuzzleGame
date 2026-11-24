import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../../../app/theme/game_themes.dart';
import '../../../data/models/puzzle.dart';
import '../game_controller.dart';

/// The crossword grid. Scales to fit; large grids can be pinch-zoomed.
class BoardView extends StatelessWidget {
  const BoardView({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final p = controller.p;
        const pad = 10.0;
        // The 1px border is added on top of the padding, so count it in the frame.
        const edge = pad + 1;
        final gapRatio = 0.11;
        final byW = (box.maxWidth - edge * 2) / (p.width + (p.width - 1) * gapRatio);
        final byH = (box.maxHeight - edge * 2) / (p.height + (p.height - 1) * gapRatio);
        final size = math.min(56.0, math.min(byW, byH));
        final gap = size * gapRatio;
        final boardW = p.width * size + (p.width - 1) * gap + edge * 2;
        final boardH = p.height * size + (p.height - 1) * gap + edge * 2;
        final needsZoom = size < 32;

        final board = Obx(() {
          final theme = controller.theme;
          final highlighted = controller.highlighted;
          // Touch reactive collections so Obx rebuilds on change.
          controller.placed.length;
          controller.wrongCells.length;
          controller.flashCells.length;
          controller.selected.value;
          controller.shakeTick.value;
          return Container(
            width: boardW,
            height: boardH,
            padding: const EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: theme.board,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.isLight ? const Color(0x22000000) : AppColors.lineSoft),
            ),
            child: Stack(
              clipBehavior: Clip.none, // keep the selected cell's glow visible
              children: [
                for (var i = 0; i < p.cells.length; i++)
                  if (!p.cells[i].isEmpty)
                    Positioned(
                      left: p.col(i) * (size + gap),
                      top: p.row(i) * (size + gap),
                      width: size,
                      height: size,
                      child: _cell(i, size, theme, highlighted.contains(i)),
                    ),
              ],
            ),
          );
        });

        return Center(
          child: needsZoom
              ? InteractiveViewer(
                  maxScale: 2.6,
                  minScale: 1,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: board,
                )
              : board,
        );
      },
    );
  }

  Widget _cell(int i, double s, GameTheme theme, bool highlighted) {
    final p = controller.p;
    final cell = p.cells[i];
    final scale = controller.settings.numberScale;
    final flash = controller.flashCells.contains(i);

    if (!p.isBlank(i)) {
      final isNum = cell.isNumber;
      final text = cell.text;
      final fontSize = (text.length >= 3 ? s * 0.34 : (text.length == 2 ? s * 0.4 : s * 0.46)) * scale;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: flash
              ? theme.accent.withValues(alpha: 0.35)
              : isNum
              ? (highlighted ? theme.highlightCell : theme.cell)
              : (highlighted ? theme.highlightCell.withValues(alpha: 0.6) : theme.opCell),
          borderRadius: BorderRadius.circular(s * 0.24),
          border: isNum && !theme.isLight
              ? Border.all(color: Color.lerp(theme.cell, Colors.white, 0.08)!)
              : null,
        ),
        child: Text(
          text,
          style: AppText.display(
            fontSize,
            weight: FontWeight.w700,
            color: isNum
                ? theme.cellText
                : (cell.kind == CellKind.equals ? theme.cellText.withValues(alpha: 0.6) : theme.op),
          ),
        ),
      );
    }

    final value = controller.placed[i];
    final selected = controller.selected.value == i;
    final wrong = controller.wrongCells.contains(i);
    final correct = value != null && controller.autoCheck && controller.isCorrect(i);
    final text = value?.toString() ?? '';
    final fontSize = (text.length >= 3 ? s * 0.34 : (text.length == 2 ? s * 0.4 : s * 0.46)) * scale;

    Color bg;
    Color fg;
    Color? border;
    if (wrong) {
      bg = AppColors.coral.withValues(alpha: 0.16);
      fg = AppColors.coral;
      border = AppColors.coral;
    } else if (correct) {
      bg = AppColors.mint.withValues(alpha: 0.14);
      fg = AppColors.mint;
      border = AppColors.mint.withValues(alpha: 0.55);
    } else if (value != null) {
      bg = theme.accent.withValues(alpha: 0.14);
      fg = theme.isLight ? theme.accent : theme.accent;
      border = theme.accent.withValues(alpha: 0.5);
    } else {
      bg = selected ? theme.accent.withValues(alpha: 0.10) : Colors.transparent;
      fg = theme.accent;
      border = null;
    }
    if (flash) bg = theme.accent.withValues(alpha: 0.35);

    Widget child = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(s * 0.24),
        border: selected
            ? Border.all(color: theme.accent, width: 2)
            : (border != null ? Border.all(color: border, width: 1.5) : null),
        boxShadow: selected
            ? [BoxShadow(color: theme.accent.withValues(alpha: 0.28), spreadRadius: 3)]
            : null,
      ),
      child: value == null
          ? (selected
                ? null
                : CustomPaint(size: Size(s, s), painter: _DashedRect(theme.emptyBorder, s * 0.24)))
          : Text(
                  text,
                  style: AppText.display(fontSize, weight: FontWeight.w700, color: fg),
                )
                .animate(key: ValueKey('v$i$value'))
                .scale(begin: const Offset(0.6, 0.6), duration: 180.ms, curve: Curves.easeOutBack),
    );

    if (wrong && controller.shakeCell.value == i) {
      child = child
          .animate(key: ValueKey('shake${controller.shakeTick.value}'))
          .shakeX(duration: 320.ms, hz: 6, amount: 4);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: 'Row ${p.row(i) + 1}, column ${p.col(i) + 1}, ${value == null ? 'empty' : '$value'}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.tapCell(i),
        child: child,
      ),
    );
  }
}

class _DashedRect extends CustomPainter {
  _DashedRect(this.color, this.radius);
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 4), paint);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRect old) => old.color != color || old.radius != radius;
}
