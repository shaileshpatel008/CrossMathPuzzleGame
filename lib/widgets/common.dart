import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import '../data/services/connectivity_service.dart';
import '../data/services/progress_service.dart';
import '../data/services/purchase_service.dart';
import 'buttons.dart';

/// Rounded surface card.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.borderWidth = 1,
    this.radius = 22,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor, width: borderWidth),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Back button + title + optional actions.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.title, this.actions = const [], this.onBack});
  final String title;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
      child: Row(
        children: [
          IconSquareButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Back',
            size: 30,
            onPressed: onBack ?? () => Get.back(),
          ),
          Expanded(
            child: Text(title, style: AppText.display(22), overflow: TextOverflow.ellipsis),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// The 2×2 operator tile logo.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 40, this.angle = -0.1});
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final pad = size * 0.13;
    final gap = size * 0.075;
    Widget tile(String s) => Container(
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(size * 0.1)),
      alignment: Alignment.center,
      child: Text(s, style: AppText.display(size * 0.27, color: AppColors.gold, height: 1)),
    );
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: size > 60
              ? [
                  BoxShadow(color: AppColors.goldShadow, offset: Offset(0, size * 0.1)),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 50,
                    offset: const Offset(0, 24),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile('+')),
                  SizedBox(width: gap),
                  Expanded(child: tile('×')),
                ],
              ),
            ),
            SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile('−')),
                  SizedBox(width: gap),
                  Expanded(child: tile('=')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hint balance pill with "+" (opens Store). Shows ∞ for VIP.
class HintPill extends StatelessWidget {
  const HintPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vip = PurchaseService.to.isVip;
      return Semantics(
        button: true,
        label: vip ? 'Unlimited hints' : '${ProgressService.to.hints.value} hints, get more',
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.toNamed(Routes.store),
          child: Container(
            height: 36,
            padding: const EdgeInsets.only(left: 10, right: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.gold, size: 17),
                const SizedBox(width: 5),
                Text(
                  vip ? '∞' : '${ProgressService.to.hints.value}',
                  style: AppText.body(14, weight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, color: AppColors.onGold, size: 20),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Small uppercase section label.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 10)});
  final String text;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(text.toUpperCase(), style: AppText.label()),
  );
}

/// Row of stars (filled count of 3).
class StarRow extends StatelessWidget {
  const StarRow(this.stars, {super.key, this.size = 12, this.dim = AppColors.line});
  final int stars;
  final double size;
  final Color dim;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < 3; i++)
        Icon(Icons.star_rounded, size: size, color: i < stars ? AppColors.gold : dim),
    ],
  );
}

/// Compact stat tile.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.valueColor, this.caption});
  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      children: [
        Text(label, style: AppText.muted(11, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: AppText.display(20, color: valueColor ?? AppColors.text)),
        if (caption != null) ...[
          const SizedBox(height: 2),
          Text(caption!, style: AppText.muted(10, weight: FontWeight.w700)),
        ],
      ],
    ),
  );
}

/// Progress bar.
class ProgressBar extends StatelessWidget {
  const ProgressBar(
    this.value, {
    super.key,
    this.color = AppColors.mint,
    this.height = 8,
    this.track = AppColors.bg,
  });
  final double value;
  final Color color;
  final double height;
  final Color track;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height / 2),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      color: color,
      backgroundColor: track,
    ),
  );
}

/// Red "You're offline" strip.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 0)});
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (ConnectivityService.to.online.value) return const SizedBox.shrink();
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6B2F3A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.coral, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "You're offline. ",
                    style: AppText.body(13, weight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'Puzzles still work — videos and store need internet.',
                    style: AppText.body(13, color: const Color(0xFFE3C3C9)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

/// Rounded icon badge.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.color = AppColors.gold, this.size = 44, this.filled = false});
  final IconData icon;
  final Color color;
  final double size;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: filled ? color : color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(size * 0.3),
    ),
    child: Icon(icon, size: size * 0.5, color: filled ? AppColors.bg : color),
  );
}
