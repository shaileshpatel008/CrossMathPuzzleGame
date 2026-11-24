import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/constants/app_constants.dart';
import '../app/routes/app_routes.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text.dart';
import '../data/services/ads_service.dart';
import '../data/services/audio_service.dart';
import '../data/services/progress_service.dart';
import 'buttons.dart';
import 'common.dart';

/// Centered rounded dialog card used by every popup in the app.
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.children, this.onClose, this.padding});
  final List<Widget> children;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.line),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 80,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: padding ?? const EdgeInsets.fromLTRB(20, 28, 20, 18),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
            if (onClose != null)
              Positioned(
                top: 6,
                right: 6,
                child: IconSquareButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  color: AppColors.muted,
                  onPressed: onClose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet shell with a grab handle.
class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      border: Border(top: BorderSide(color: AppColors.line)),
    ),
    padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + MediaQuery.of(context).padding.bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(color: AppColors.lineDashed, borderRadius: BorderRadius.circular(3)),
        ),
        ...children,
      ],
    ),
  );
}

class Dialogs {
  Dialogs._();

  static Future<T?> sheet<T>(Widget child) => Get.bottomSheet<T>(
    child,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
  );

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final r = await Get.dialog<bool>(
      AppDialog(
        children: [
          Text(title, textAlign: TextAlign.center, style: AppText.display(22)),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: AppText.muted(14).copyWith(height: 1.5)),
          const SizedBox(height: 22),
          PrimaryButton(
            label: confirmLabel,
            tone: destructive ? ButtonTone.coral : ButtonTone.gold,
            onPressed: () => Get.back(result: true),
          ),
          const SizedBox(height: 8),
          TextLinkButton(cancelLabel, onPressed: () => Get.back(result: false)),
        ],
      ),
    );
    return r ?? false;
  }

  static Future<void> info(String title, String message) => Get.dialog(
    AppDialog(
      children: [
        Text(title, textAlign: TextAlign.center, style: AppText.display(22)),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center, style: AppText.muted(14).copyWith(height: 1.5)),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Got it', onPressed: () => Get.back()),
      ],
    ),
  );

  static void toast(
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color color = AppColors.mint,
  }) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AppText.body(14, weight: FontWeight.w600)),
          ),
        ],
      ),
      backgroundColor: AppColors.surface2,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Blocking "Connecting to Google Play…" loader (checkout step).
  static bool _connecting = false;

  static void showConnecting() {
    if (_connecting) return;
    _connecting = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: AppDialog(
          children: [
            const SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppColors.gold,
                backgroundColor: AppColors.line,
              ),
            ),
            const SizedBox(height: 16),
            Text('Connecting to Google Play…', textAlign: TextAlign.center, style: AppText.display(18)),
            const SizedBox(height: 8),
            Text(
              'Payment is handled securely by Google. We never see your card details.',
              textAlign: TextAlign.center,
              style: AppText.muted(13).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      name: 'connecting',
    ).whenComplete(() => _connecting = false);
  }

  static void hideConnecting() {
    if (_connecting && (Get.isDialogOpen ?? false)) {
      _connecting = false;
      Get.back();
    }
  }

  /// "No video right now" (artboard 28).
  static Future<void> adUnavailable() => Get.dialog(
    AppDialog(
      children: [
        const IconBadge(Icons.videocam_off_rounded, color: AppColors.muted, size: 76),
        const SizedBox(height: 18),
        Text('No video right now', style: AppText.display(23)),
        const SizedBox(height: 10),
        Text(
          "We couldn't load a reward video. Check your connection and try again in a moment.",
          textAlign: TextAlign.center,
          style: AppText.muted(14).copyWith(height: 1.55),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Try again',
          onPressed: () => Get.back(result: 'retry'),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Get hints in the store',
          onPressed: () {
            Get.back();
            Get.toNamed(Routes.store);
          },
        ),
        TextLinkButton('Back', onPressed: () => Get.back()),
      ],
    ),
  );

  /// Plays a reward video; shows the "unavailable" dialog on failure.
  /// Resolves true only if the reward was earned.
  static Future<bool> watchRewarded() async {
    while (true) {
      final result = await AdsService.to.showRewarded();
      if (result != null) {
        if (result) AudioService.to.play(Sfx.reward);
        return result;
      }
      final r = await Get.dialog(
        AppDialog(
          children: [
            const IconBadge(Icons.videocam_off_rounded, color: AppColors.muted, size: 76),
            const SizedBox(height: 18),
            Text('No video right now', style: AppText.display(23)),
            const SizedBox(height: 10),
            Text(
              "We couldn't load a reward video. Check your connection and try again in a moment.",
              textAlign: TextAlign.center,
              style: AppText.muted(14).copyWith(height: 1.55),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Try again',
              onPressed: () => Get.back(result: 'retry'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Get hints in the store',
              onPressed: () => Get.back(result: 'store'),
            ),
            TextLinkButton('Back', onPressed: () => Get.back()),
          ],
        ),
      );
      if (r == 'store') {
        Get.toNamed(Routes.store);
        return false;
      }
      if (r != 'retry') return false;
    }
  }

  static Future<void> rateUs() => Get.dialog(const RateUsDialog());
}

/// Rate us (artboard 26): 4–5★ → Google Play review, 1–3★ → feedback e-mail.
class RateUsDialog extends StatefulWidget {
  const RateUsDialog({super.key});
  @override
  State<RateUsDialog> createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog> {
  int _rating = 0;
  final _feedback = TextEditingController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _rateOnPlay() async {
    ProgressService.to.markRated();
    Get.back();
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    } else {
      await review.openStoreListing();
    }
  }

  Future<void> _sendFeedback() async {
    ProgressService.to.markRated();
    Get.back();
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {'subject': '${AppConstants.shortName} feedback ($_rating★)', 'body': _feedback.text},
    );
    await launchUrl(uri);
    Dialogs.toast('Thanks for your feedback!');
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      onClose: () => Get.back(),
      children: [
        const LogoMark(size: 72),
        const SizedBox(height: 20),
        Text('Enjoying CrossMath Puzzle?', textAlign: TextAlign.center, style: AppText.display(22)),
        const SizedBox(height: 8),
        Text('Tap a star to rate your experience', style: AppText.muted(14)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: '$i stars',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () => setState(() => _rating = i),
                icon: Icon(
                  Icons.star_rounded,
                  size: 40,
                  color: i <= _rating ? AppColors.gold : AppColors.line,
                ),
              ),
          ],
        ),
        if (_rating > 0 && _rating <= 3) ...[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('What can we do better?', style: AppText.body(13, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedback,
            maxLines: 3,
            style: AppText.body(14),
            decoration: InputDecoration(
              hintText: 'Tell us what went wrong…',
              hintStyle: AppText.body(14, color: AppColors.dim),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.line),
              ),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Send feedback', onPressed: _sendFeedback),
        ],
        if (_rating >= 4) ...[
          const SizedBox(height: 14),
          Text(
            'Thank you! A quick review on Google Play helps a lot.',
            textAlign: TextAlign.center,
            style: AppText.body(14),
          ),
          const SizedBox(height: 14),
          PrimaryButton(label: 'Rate on Google Play', onPressed: _rateOnPlay),
        ],
        TextLinkButton('Maybe later', onPressed: () => Get.back()),
      ],
    );
  }
}
