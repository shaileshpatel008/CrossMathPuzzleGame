import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/game_themes.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../data/services/settings_service.dart';
import '../../widgets/dialogs.dart';

class ThemesController extends GetxController {
  SettingsService get settings => SettingsService.to;
  late final preview = settings.themeId.value.obs;

  GameTheme get previewTheme => GameTheme.byId(preview.value);

  bool unlocked(GameTheme t) => switch (t.unlock) {
    ThemeUnlock.free => true,
    ThemeUnlock.dailyGift => PurchaseService.to.isVip || ProgressService.to.unlockedThemes.contains(t.id),
    ThemeUnlock.level200 => PurchaseService.to.isVip || ProgressService.to.currentLevel.value > 200,
    ThemeUnlock.vip => PurchaseService.to.isVip,
  };

  void apply() {
    final t = previewTheme;
    if (unlocked(t)) {
      settings.themeId.value = t.id;
      Dialogs.toast('${t.name} theme applied');
      return;
    }
    switch (t.unlock) {
      case ThemeUnlock.vip:
        Get.toNamed(Routes.vip);
      case ThemeUnlock.dailyGift:
        Dialogs.info(
          'Ocean theme',
          'Claim your Day-7 Daily Gift to unlock Ocean — or get VIP to unlock every theme.',
        );
      case ThemeUnlock.level200:
        Dialogs.info(
          'Forest theme',
          'Reach journey level 200 to unlock Forest — or get VIP to unlock every theme.',
        );
      case ThemeUnlock.free:
        break;
    }
  }
}
