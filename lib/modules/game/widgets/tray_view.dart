import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text.dart';
import '../game_controller.dart';

/// Number tiles. Identical values are grouped with a count badge.
class TrayView extends StatelessWidget {
  const TrayView({super.key, required this.controller});
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final values = controller.trayValues;
        final perRow = values.length <= 5 ? values.length : (values.length <= 10 ? 5 : 6);
        final w = ((box.maxWidth - (perRow - 1) * 8) / perRow).clamp(44.0, 66.0);
        final h = w > 56 ? 52.0 : 46.0;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: h * 3 + 16 + 12),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8),
            child: Obx(() {
              controller.placed.length;
              final theme = controller.theme;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: [
                  for (final v in values)
                    _Tile(
                      value: v,
                      remaining: controller.remaining(v),
                      width: w,
                      height: h,
                      color: theme.accent,
                      shadow: theme.accentShadow,
                      textColor: theme.tileText,
                      usedColor: theme.usedTile,
                      usedText: theme.usedTileText,
                      onTap: () => controller.tapTile(v),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _Tile extends StatefulWidget {
  const _Tile({
    required this.value,
    required this.remaining,
    required this.width,
    required this.height,
    required this.color,
    required this.shadow,
    required this.textColor,
    required this.usedColor,
    required this.usedText,
    required this.onTap,
  });

  final int value;
  final int remaining;
  final double width;
  final double height;
  final Color color;
  final Color shadow;
  final Color textColor;
  final Color usedColor;
  final Color usedText;
  final VoidCallback onTap;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.remaining > 0;
    final depth = !enabled ? 0.0 : (_down ? 1.0 : 4.0);
    final text = '${widget.value}';
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Number ${widget.value}${widget.remaining > 1 ? ', ${widget.remaining} left' : ''}',
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled ? widget.onTap : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                left: 0,
                right: 0,
                top: 4 - depth,
                height: widget.height,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: enabled ? widget.color : widget.usedColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: enabled ? [BoxShadow(color: widget.shadow, offset: Offset(0, depth))] : null,
                  ),
                  child: Text(
                    text,
                    style: AppText.display(
                      text.length >= 3 ? 18 : 22,
                      color: enabled ? widget.textColor : widget.usedText,
                    ),
                  ),
                ),
              ),
              if (widget.remaining > 1)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.violet,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.bg, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '×${widget.remaining}',
                      style: AppText.body(10, weight: FontWeight.w800, color: AppColors.bg),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
