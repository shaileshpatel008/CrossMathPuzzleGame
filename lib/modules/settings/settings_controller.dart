import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../data/services/settings_service.dart';
import '../../widgets/dialogs.dart';

class SettingsController extends GetxController {
  SettingsService get s => SettingsService.to;
  PurchaseService get iap => PurchaseService.to;
  final version = ''.obs;

  @override
  void onInit() {
    super.onInit();
    PackageInfo.fromPlatform().then((i) => version.value = '${i.version} (${i.buildNumber})');
  }

  Future<void> toggleReminder(bool on) async {
    if (on) await NotificationService.to.requestPermission();
    s.reminder.value = on;
  }

  Future<void> pickReminderTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.reminderHour.value, minute: s.reminderMinute.value),
    );
    if (t == null) return;
    s.reminderHour.value = t.hour;
    s.reminderMinute.value = t.minute;
  }

  String reminderLabel(BuildContext context) =>
      TimeOfDay(hour: s.reminderHour.value, minute: s.reminderMinute.value).format(context);

  Future<void> privacyOptions() async {
    final shown = await AdsService.to.showPrivacyOptions();
    if (!shown) {
      Dialogs.info(
        'Privacy options',
        'Ad-consent choices are not required in your region. Ads may still be personalised based on your device settings.',
      );
    }
  }

  void open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  void share() => SharePlus.instance.share(
    ShareParams(
      text:
          "I'm training my brain with ${AppConstants.shortName} — crossword-style maths puzzles. "
          'Try it: ${AppConstants.playStoreUrl}',
    ),
  );

  void contact() => launchUrl(
    Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
      queryParameters: {'subject': '${AppConstants.shortName} support (v${version.value})'},
    ),
  );

  void language() => Dialogs.sheet(
    AppSheet(
      children: [
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Language', style: AppText.display(22)),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text('English', style: AppText.body(15, weight: FontWeight.w600)),
          trailing: const Icon(Icons.check_rounded, color: AppColors.mint),
          onTap: () => Get.back(),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );

  Future<void> resetProgress() async {
    final ok = await Dialogs.confirm(
      title: 'Reset all progress?',
      message:
          'Levels, stars, stats, daily records and awards will be erased. Purchases and hints are kept. This cannot be undone.',
      confirmLabel: 'Reset progress',
      destructive: true,
    );
    if (!ok) return;
    await ProgressService.to.resetProgress();
    Dialogs.toast('Progress reset');
  }
}
