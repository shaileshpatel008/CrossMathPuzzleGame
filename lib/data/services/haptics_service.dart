import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'settings_service.dart';

/// Haptic feedback that respects the Vibration setting.
class HapticsService extends GetxService {
  static HapticsService get to => Get.find();

  bool get _on => SettingsService.to.vibration.value;

  void tap() {
    if (_on) HapticFeedback.selectionClick();
  }

  void light() {
    if (_on) HapticFeedback.lightImpact();
  }

  void medium() {
    if (_on) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (_on) HapticFeedback.heavyImpact();
  }
}
