import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common.dart';
import '../../widgets/decorations.dart';
import 'purchase_flow_controller.dart';

/// Artboard 20 — Purchase success.
class PurchaseSuccessView extends StatelessWidget {
  const PurchaseSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments as String? ?? IapIds.removeAds;
    final (title, body, items) = _content(id);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: SymbolConfetti(symbols: false, count: 22)),
            Column(
              children: [
                const Spacer(flex: 2),
                const Glow(
                  color: AppColors.mint,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.mint,
                    child: Icon(Icons.check_rounded, size: 64, color: AppColors.onMint),
                  ),
                ),
                const SizedBox(height: 14),
                Text(title, textAlign: TextAlign.center, style: AppText.display(30)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 10, 32, 0),
                  child: Text(
                    body,
                    textAlign: TextAlign.center,
                    style: AppText.muted(15).copyWith(height: 1.55),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        for (final (text, plus) in items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                IconBadge(
                                  plus ? Icons.add_rounded : Icons.check_rounded,
                                  color: plus ? AppColors.gold : AppColors.mint,
                                  size: 26,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(text, style: AppText.body(14))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Restorable on any device signed in to the same Google account',
                  textAlign: TextAlign.center,
                  style: AppText.muted(12),
                ),
                const Spacer(flex: 3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: PrimaryButton(
                    label: 'Keep playing',
                    height: 60,
                    fontSize: 18,
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String, String, List<(String, bool)>) _content(String id) {
    if (IapIds.subscriptions.contains(id)) {
      return (
        'Welcome to VIP!',
        'Thanks for supporting CrossMath Puzzle. Every VIP perk is now unlocked.',
        [
          ('No ads, ever', false),
          ('Unlimited hints', false),
          ('Master mode & every past daily', false),
          ('Free second chances & VIP themes', false),
        ],
      );
    }
    if (IapIds.consumables.contains(id)) {
      return (
        '+${IapIds.hintAmounts[id]} hints added!',
        'Your hints are ready to use on any puzzle.',
        [('${IapIds.hintAmounts[id]} hints added to your balance', true)],
      );
    }
    return (
      id == IapIds.starterPack ? 'Starter Pack unlocked!' : 'Ads removed!',
      'Thanks for supporting CrossMath Puzzle. Enjoy every puzzle without interruptions.',
      [
        ('Banner ads removed', false),
        ('Interstitial & app-open ads removed', false),
        ('Exit-dialog ads removed', false),
        if (id == IapIds.starterPack) ('30 hints added', true),
        ('Optional reward videos still available', true),
      ],
    );
  }
}

/// Artboard 21 — Pending / failed / restored / nothing to restore.
class PurchaseStatusView extends StatelessWidget {
  const PurchaseStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Map<String, dynamic>.from(Get.arguments as Map? ?? {});
    final state = args['state'] as String? ?? 'failed';
    final restored = (args['restored'] as List?)?.cast<String>() ?? const <String>[];

    final (
      IconData icon,
      Color color,
      String title,
      String body,
      String cta,
      VoidCallback onCta,
      String link,
      VoidCallback onLink,
    ) = switch (state) {
      'pending' => (
        Icons.schedule_rounded,
        AppColors.gold,
        'Payment pending',
        'Google Play is still confirming your payment (for example cash or bank transfer). '
            'Your purchase unlocks automatically as soon as it clears — you can keep playing.',
        'Got it',
        () => Get.back(),
        'Contact support',
        _contact,
      ),
      'restored' => (
        Icons.check_rounded,
        AppColors.mint,
        'Purchases restored',
        'We found these on your Google account:',
        'Continue',
        () => Get.back(),
        'Manage subscription',
        () => launchUrl(Uri.parse(AppConstants.manageSubscriptionsUrl), mode: LaunchMode.externalApplication),
      ),
      'none' => (
        Icons.search_rounded,
        AppColors.muted,
        'Nothing to restore',
        'No previous purchases were found for this Google account. Make sure you are signed in '
            'with the account you bought with.',
        'Go to store',
        () => Get.offNamed(Routes.store),
        'Contact support',
        _contact,
      ),
      _ => (
        Icons.close_rounded,
        AppColors.coral,
        'Purchase not completed',
        'The payment was cancelled or declined. You have not been charged. Please try again or '
            'use another payment method in Google Play.${args['message'] != null ? '\n\n(${args['message']})' : ''}',
        'Back to store',
        () => Get.back(),
        'Restore purchases',
        () {
          Get.back();
          PurchaseFlowController.to.restore();
        },
      ),
    };

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: AppCard(
              radius: 30,
              padding: const EdgeInsets.fromLTRB(22, 30, 22, 18),
              child: Column(
                children: [
                  IconBadge(icon, color: color, size: 76),
                  const SizedBox(height: 18),
                  Text(title, textAlign: TextAlign.center, style: AppText.display(23)),
                  const SizedBox(height: 10),
                  Text(body, textAlign: TextAlign.center, style: AppText.muted(14).copyWith(height: 1.55)),
                  if (state == 'restored') ...[
                    const SizedBox(height: 16),
                    for (final id in restored.toSet())
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(IapIds.title(id), style: AppText.body(14))),
                            Text(
                              IapIds.subscriptions.contains(id) ? 'Active' : 'Restored',
                              style: AppText.body(14, weight: FontWeight.w700, color: AppColors.mint),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(label: cta, onPressed: onCta),
                  TextLinkButton(link, onPressed: onLink, color: AppColors.gold),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _contact() => launchUrl(
    Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {'subject': '${AppConstants.shortName} purchase help'},
    ),
  );
}
