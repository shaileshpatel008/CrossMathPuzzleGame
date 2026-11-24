import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/iap_config.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/services/update_service.dart';
import '../../widgets/common.dart';
import '../../widgets/dialogs.dart';
import '../purchase/purchase_flow_controller.dart';
import 'settings_controller.dart';

/// Artboard 25 — Settings.
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = controller.s;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Settings'),
            Expanded(
              child: Obx(() {
                final vip = controller.iap.isVip;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    AppCard(
                      color: AppColors.vipSurface,
                      borderColor: AppColors.vipLine,
                      radius: 20,
                      onTap: () => Get.toNamed(Routes.vip),
                      child: Row(
                        children: [
                          const IconBadge(
                            Icons.workspace_premium_rounded,
                            color: AppColors.gold,
                            size: 40,
                            filled: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vip ? 'VIP member' : 'Free plan', style: AppText.display(15)),
                                const SizedBox(height: 2),
                                Text(
                                  vip ? 'All perks are active' : 'Go VIP: no ads, unlimited hints',
                                  style: AppText.body(12, color: AppColors.violetSoft),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            vip ? 'Manage' : 'Upgrade',
                            style: AppText.body(13, weight: FontWeight.w800, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    _section('Gameplay', [
                      _toggle('Auto-check mistakes', s.autoCheck, sub: 'Wrong numbers turn red instantly'),
                      _toggle('Show timer', s.showTimer),
                      _toggle('Relaxed mode', s.relaxedMode, sub: 'No mistake limit · no stars or awards'),
                    ]),
                    _section('Sound & feel', [
                      _toggle('Sound effects', s.sfx),
                      _toggle('Music', s.music),
                      _toggle('Vibration', s.vibration),
                    ]),
                    _section('Appearance', [
                      _link('Themes', value: s.theme.name, onTap: () => Get.toNamed(Routes.themes)),
                      _link('Language', value: 'English', onTap: controller.language),
                    ]),
                    _section('Notifications', [
                      _switchRow(
                        'Daily challenge reminder',
                        s.reminder.value,
                        controller.toggleReminder,
                        sub: 'Every day at ${controller.reminderLabel(context)}',
                      ),
                      if (s.reminder.value)
                        _link(
                          'Reminder time',
                          value: controller.reminderLabel(context),
                          onTap: () => controller.pickReminderTime(context),
                        ),
                    ]),
                    _section('Purchases', [
                      _link(
                        'Remove ads',
                        value: controller.iap.adsRemoved ? 'Owned' : controller.iap.price(IapIds.removeAds),
                        onTap: () => Get.toNamed(Routes.store),
                      ),
                      _link('Restore purchases', onTap: () => PurchaseFlowController.to.restore()),
                      _link(
                        'Manage subscription',
                        value: 'Google Play',
                        onTap: () => controller.open(AppConstants.manageSubscriptionsUrl),
                      ),
                    ]),
                    _section('Privacy & legal', [
                      _link('Privacy options (ads consent)', onTap: controller.privacyOptions),
                      _link('Privacy policy', onTap: () => controller.open(AppConstants.privacyPolicyUrl)),
                      _link('Terms of use', onTap: () => controller.open(AppConstants.termsUrl)),
                    ]),
                    _section('Support', [
                      _link('Rate CrossMath Puzzle', onTap: Dialogs.rateUs),
                      _link('Share with friends', onTap: controller.share),
                      _link('Contact support', onTap: controller.contact),
                      _link(
                        'How to play',
                        onTap: () => Get.toNamed(Routes.onboarding, arguments: 'fromGame'),
                      ),
                    ]),
                    _section('App', [
                      _link(
                        UpdateService.to.checking.value ? 'Checking for updates…' : 'Check for updates',
                        value: 'v${UpdateService.to.currentVersion.value}',
                        onTap: UpdateService.to.checkNow,
                      ),
                    ]),
                    _section('Data', [
                      _link('Reset all progress', danger: true, onTap: controller.resetProgress),
                    ]),
                    const SizedBox(height: 24),
                    Text(AppConstants.appName, textAlign: TextAlign.center, style: AppText.muted(11)),
                    const SizedBox(height: 4),
                    Text(
                      'Version ${controller.version.value} · ${AppConstants.packageName}',
                      textAlign: TextAlign.center,
                      style: AppText.body(11, color: AppColors.dim),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionLabel(title, padding: const EdgeInsets.fromLTRB(6, 22, 6, 8)),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.lineSoft),
              rows[i],
            ],
          ],
        ),
      ),
    ],
  );

  Widget _toggle(String title, RxBool value, {String? sub}) =>
      _switchRow(title, value.value, (v) => value.value = v, sub: sub);

  Widget _switchRow(String title, bool value, ValueChanged<bool> onChanged, {String? sub}) => SwitchListTile(
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    title: Text(title, style: AppText.body(14, weight: FontWeight.w600)),
    subtitle: sub == null ? null : Text(sub, style: AppText.muted(12)),
  );

  Widget _link(String title, {String? value, bool danger = false, required VoidCallback onTap}) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    minTileHeight: 48,
    title: Text(
      title,
      style: AppText.body(14, weight: FontWeight.w600, color: danger ? AppColors.coral : AppColors.text),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value != null) Text(value, style: AppText.muted(13)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: AppColors.dim, size: 20),
      ],
    ),
  );
}
