import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/services/settings_service.dart';

/// Artboard 03 — How to play (3 pages). Also opened from Pause (`fromGame`).
class OnboardingController extends GetxController {
  final page = 0.obs;
  final pageController = PageController();
  late final bool fromGame = Get.arguments == 'fromGame';

  static const pages = 3;

  void onPageChanged(int i) => page.value = i;

  void next() {
    if (page.value < pages - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      tryIt();
    }
  }

  void tryIt() {
    if (fromGame) {
      Get.back();
      return;
    }
    Get.offAllNamed(Routes.tutorial);
  }

  void skip() {
    if (fromGame) {
      Get.back();
      return;
    }
    SettingsService.to.onboardingDone.value = true;
    Get.offAllNamed(Routes.home);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
