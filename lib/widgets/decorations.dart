import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import '../data/models/difficulty.dart';

/// Decorative 5×5 board used on Home (three gold dashed blanks).
class MiniBoard extends StatelessWidget {
  const MiniBoard({super.key, this.cell = 30});
  final double cell;

  static const _rows = [
    ['8', Ops.sub, '', '=', '5'],
    [Ops.div, ' ', Ops.add, ' ', Ops.add],
    ['', Ops.add, '4', '=', '6'],
    ['=', ' ', '=', ' ', '='],
    ['4', Ops.add, '7', '=', ''],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lineSoft),
        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.10), blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var r = 0; r < 5; r++)
            Padding(
              padding: EdgeInsets.only(bottom: r == 4 ? 0 : 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 5; c++)
                    Padding(
                      padding: EdgeInsets.only(right: c == 4 ? 0 : 5),
                      child: _cell(_rows[r][c]),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(String t) {
    final isNum = int.tryParse(t) != null;
    final blank = t.isEmpty;
    final space = t == ' ';
    return Container(
      width: cell,
      height: cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isNum
            ? AppColors.surface2
            : (blank ? AppColors.gold.withValues(alpha: 0.08) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
        border: isNum
            ? Border.all(color: AppColors.line)
            : blank
            ? Border.all(color: AppColors.gold, width: 1.5)
            : null,
      ),
      child: space
          ? null
          : Text(
              t,
              style: AppText.display(
                cell * 0.47,
                weight: FontWeight.w700,
                color: isNum ? AppColors.text : AppColors.violet,
              ),
            ),
    );
  }
}

/// Falling maths-symbol confetti (Level complete / purchase success).
class SymbolConfetti extends StatefulWidget {
  const SymbolConfetti({super.key, this.count = 26, this.symbols = true});
  final int count;
  final bool symbols;
  @override
  State<SymbolConfetti> createState() => _SymbolConfettiState();
}

class _SymbolConfettiState extends State<SymbolConfetti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();
  late final List<_Piece> _pieces;

  @override
  void initState() {
    super.initState();
    final r = math.Random();
    const sym = ['+', '×', '−', '÷', '=', '7', '3', '9', '12', '4'];
    const col = [
      AppColors.gold,
      AppColors.mint,
      AppColors.violet,
      AppColors.coral,
      AppColors.sky,
      AppColors.ember,
    ];
    _pieces = List.generate(widget.count, (i) {
      return _Piece(
        x: r.nextDouble(),
        delay: r.nextDouble() * 0.35,
        speed: 0.55 + r.nextDouble() * 0.6,
        drift: (r.nextDouble() - 0.5) * 0.2,
        spin: (r.nextDouble() - 0.5) * 6,
        size: 16 + r.nextDouble() * 18,
        text: sym[r.nextInt(sym.length)],
        color: col[r.nextInt(col.length)],
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => LayoutBuilder(
          builder: (context, box) {
            return Stack(
              children: [
                for (final p in _pieces)
                  () {
                    final t = ((_c.value - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
                    if (t <= 0) return const SizedBox.shrink();
                    final y = -40 + t * p.speed * (box.maxHeight + 80);
                    final x = (p.x + p.drift * t) * box.maxWidth;
                    return Positioned(
                      left: x,
                      top: y,
                      child: Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0) * 0.9,
                        child: Transform.rotate(
                          angle: p.spin * t,
                          child: widget.symbols
                              ? Text(p.text, style: AppText.display(p.size, color: p.color))
                              : Container(
                                  width: p.size * 0.45,
                                  height: p.size * 0.8,
                                  decoration: BoxDecoration(
                                    color: p.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                        ),
                      ),
                    );
                  }(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Piece {
  _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.text,
    required this.color,
  });
  final double x, delay, speed, drift, spin, size;
  final String text;
  final Color color;
}

/// Soft radial glow behind hero icons.
class Glow extends StatelessWidget {
  const Glow({super.key, required this.child, this.color = AppColors.gold, this.size = 200});
  final Widget child;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)]),
    ),
    alignment: Alignment.center,
    child: child,
  );
}

/// Dot-grid page background.
class DotBackground extends StatelessWidget {
  const DotBackground({super.key, required this.child, this.color = AppColors.bg});
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DotPainter(color), child: child);
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.bg);
  final Color bg;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final p = Paint()..color = const Color(0xFF1B2456);
    for (double y = 11; y < size.height; y += 22) {
      for (double x = 11; x < size.width; x += 22) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter old) => old.bg != bg;
}
