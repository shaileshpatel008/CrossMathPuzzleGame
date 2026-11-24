import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/storage_keys.dart';
import '../../app/theme/game_themes.dart';
import 'storage_service.dart';

/// User preferences. Every field is reactive and persisted automatically.
class SettingsService extends GetxService {
  static SettingsService get to => Get.find();

  final autoCheck = true.obs;
  final showTimer = true.obs;
  final relaxedMode = false.obs;
  final sfx = true.obs;
  final music = false.obs;
  final vibration = true.obs;
  final reminder = true.obs;
  final reminderHour = AppConstants.defaultReminderHour.obs;
  final reminderMinute = AppConstants.defaultReminderMinute.obs;
  final themeId = GameTheme.midnight.id.obs;
  final numberSize = 1.obs; // 0 = S, 1 = M, 2 = L
  final onboardingDone = false.obs;
  final sessionCount = 0.obs;
  final languageCode = 'en'.obs;

  GameTheme get theme => GameTheme.byId(themeId.value);
  double get numberScale => const [0.86, 1.0, 1.16][numberSize.value.clamp(0, 2)];

  SettingsService init() {
    final m = StorageService.to.readMap(StorageKeys.settings);
    autoCheck.value = m['autoCheck'] as bool? ?? true;
    showTimer.value = m['showTimer'] as bool? ?? true;
    relaxedMode.value = m['relaxed'] as bool? ?? false;
    sfx.value = m['sfx'] as bool? ?? true;
    music.value = m['music'] as bool? ?? false;
    vibration.value = m['vibration'] as bool? ?? true;
    reminder.value = m['reminder'] as bool? ?? true;
    reminderHour.value = m['reminderHour'] as int? ?? AppConstants.defaultReminderHour;
    reminderMinute.value = m['reminderMinute'] as int? ?? AppConstants.defaultReminderMinute;
    themeId.value = m['theme'] as String? ?? GameTheme.midnight.id;
    numberSize.value = m['numberSize'] as int? ?? 1;
    onboardingDone.value = m['onboardingDone'] as bool? ?? false;
    sessionCount.value = (m['sessions'] as int? ?? 0) + 1;
    languageCode.value = m['lang'] as String? ?? 'en';

    everAll([
      autoCheck,
      showTimer,
      relaxedMode,
      sfx,
      music,
      vibration,
      reminder,
      reminderHour,
      reminderMinute,
      themeId,
      numberSize,
      onboardingDone,
      sessionCount,
      languageCode,
    ], (_) => _save());
    _save();
    return this;
  }

  void _save() {
    StorageService.to.write(StorageKeys.settings, {
      'autoCheck': autoCheck.value,
      'showTimer': showTimer.value,
      'relaxed': relaxedMode.value,
      'sfx': sfx.value,
      'music': music.value,
      'vibration': vibration.value,
      'reminder': reminder.value,
      'reminderHour': reminderHour.value,
      'reminderMinute': reminderMinute.value,
      'theme': themeId.value,
      'numberSize': numberSize.value,
      'onboardingDone': onboardingDone.value,
      'sessions': sessionCount.value,
      'lang': languageCode.value,
    });
  }
}
