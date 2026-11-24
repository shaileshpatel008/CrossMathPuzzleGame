import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import '../data/services/audio_service.dart';
import '../data/services/haptics_service.dart';

enum ButtonTone { gold, mint, violet, coral, white }

/// Big 3D "game" button that sinks when pressed.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.tone = ButtonTone.gold,
    this.height = 58,
    this.fontSize = 17,
    this.expand = true,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final ButtonTone tone;
  final double height;
  final double fontSize;
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _down = false;

  (Color, Color, Color) get _colors => switch (widget.tone) {
    ButtonTone.gold => (AppColors.gold, AppColors.goldShadow, AppColors.onGold),
    ButtonTone.mint => (AppColors.mint, AppColors.mintShadow, AppColors.onMint),
    ButtonTone.violet => (AppColors.violet, AppColors.violetShadow, AppColors.bg),
    ButtonTone.coral => (AppColors.coral, const Color(0xFFB54848), AppColors.onCoral),
    ButtonTone.white => (Colors.white, const Color(0xFFBFC3DA), const Color(0xFF2A1F7A)),
  };

  @override
  Widget build(BuildContext context) {
    final (bg, shadow, fg) = _colors;
    final enabled = widget.onPressed != null;
    final depth = _down ? 1.0 : 5.0;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                HapticsService.to.light();
                AudioService.to.play(Sfx.tap);
                widget.onPressed!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: widget.height,
          width: widget.expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          margin: EdgeInsets.only(top: 5 - depth, bottom: depth),
          decoration: BoxDecoration(
            color: enabled ? bg : bg.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: shadow, offset: Offset(0, depth), blurRadius: 0)],
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: widget.fontSize + 3),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(widget.fontSize, color: fg),
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(widget.trailingIcon, color: fg, size: widget.fontSize + 2),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 50,
    this.color = AppColors.text,
    this.background,
    this.borderColor = AppColors.line,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color color;
  final Color? background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed == null
            ? null
            : () {
                HapticsService.to.tap();
                AudioService.to.play(Sfx.tap);
                onPressed!();
              },
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: color), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(15, weight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plain text button (e.g. "Not now", "Skip").
class TextLinkButton extends StatelessWidget {
  const TextLinkButton(this.label, {super.key, this.onPressed, this.color = AppColors.muted});
  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
    child: Text(
      label,
      style: AppText.body(14, weight: FontWeight.w600, color: color),
    ),
  );
}

/// 44×44 icon-only button.
class IconSquareButton extends StatelessWidget {
  const IconSquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color = AppColors.text,
    this.size = 24,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed == null
        ? null
        : () {
            HapticsService.to.tap();
            onPressed!();
          },
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    icon: Icon(icon, color: color, size: size),
  );
}
