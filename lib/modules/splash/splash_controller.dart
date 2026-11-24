import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/settings_service.dart';

/// Splash → ads consent (UMP, only where required) → SDK init → onboarding or home.
class SplashController extends GetxController {
  final progress = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _start();
  }

  Future<void> _start() async {
    final anim = _animate();
    await Future.wait([AdsService.to.gatherConsentAndInit(), anim]);
    progress.value = 1;
    if (!SettingsService.to.onboardingDone.value) {
      Get.offAllNamed(Routes.onboarding);
      return;
    }
    Get.offAllNamed(Routes.home);
    // Cold-start app-open ad (from the 2nd session, max 1 per 4 h, never for Remove Ads / VIP).
    Future<void>.delayed(const Duration(milliseconds: 600), AdsService.to.maybeShowAppOpen);
  }

  Future<void> _animate() async {
    for (var i = 1; i <= 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 70));
      progress.value = (i / 20) * 0.9;
    }
  }
}
