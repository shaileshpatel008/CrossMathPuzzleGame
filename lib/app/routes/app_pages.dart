import 'package:get/get.dart';

import '../../modules/achievements/achievements_binding.dart';
import '../../modules/achievements/achievements_view.dart';
import '../../modules/ad_break/ad_break_binding.dart';
import '../../modules/ad_break/ad_break_view.dart';
import '../../modules/daily/daily_binding.dart';
import '../../modules/daily/daily_complete_binding.dart';
import '../../modules/daily/daily_complete_view.dart';
import '../../modules/daily/daily_view.dart';
import '../../modules/game/game_binding.dart';
import '../../modules/game/game_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/level_complete/level_complete_binding.dart';
import '../../modules/level_complete/level_complete_view.dart';
import '../../modules/level_map/level_map_binding.dart';
import '../../modules/level_map/level_map_view.dart';
import '../../modules/onboarding/onboarding_binding.dart';
import '../../modules/onboarding/onboarding_view.dart';
import '../../modules/purchase/purchase_views.dart';
import '../../modules/settings/settings_binding.dart';
import '../../modules/settings/settings_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/stats/stats_binding.dart';
import '../../modules/stats/stats_view.dart';
import '../../modules/store/store_binding.dart';
import '../../modules/store/store_view.dart';
import '../../modules/themes/themes_binding.dart';
import '../../modules/themes/themes_view.dart';
import '../../modules/tutorial/tutorial_binding.dart';
import '../../modules/tutorial/tutorial_view.dart';
import '../../modules/vip/vip_binding.dart';
import '../../modules/vip/vip_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(name: Routes.splash, page: () => const SplashView(), binding: SplashBinding()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: Routes.tutorial, page: () => const TutorialView(), binding: TutorialBinding()),
    GetPage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: Routes.levelMap, page: () => const LevelMapView(), binding: LevelMapBinding()),
    GetPage(name: Routes.daily, page: () => const DailyView(), binding: DailyBinding()),
    GetPage(
      name: Routes.dailyComplete,
      page: () => const DailyCompleteView(),
      binding: DailyCompleteBinding(),
    ),
    GetPage(name: Routes.game, page: () => const GameView(), binding: GameBinding()),
    GetPage(
      name: Routes.levelComplete,
      page: () => const LevelCompleteView(),
      binding: LevelCompleteBinding(),
    ),
    GetPage(
      name: Routes.adBreak,
      page: () => const AdBreakView(),
      binding: AdBreakBinding(),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    ),
    GetPage(name: Routes.store, page: () => const StoreView(), binding: StoreBinding()),
    GetPage(
      name: Routes.vip,
      page: () => const VipView(),
      binding: VipBinding(),
      transition: Transition.downToUp,
      fullscreenDialog: true,
    ),
    GetPage(
      name: Routes.purchaseSuccess,
      page: () => const PurchaseSuccessView(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: Routes.purchaseStatus,
      page: () => const PurchaseStatusView(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: Routes.stats, page: () => const StatsView(), binding: StatsBinding()),
    GetPage(name: Routes.achievements, page: () => const AchievementsView(), binding: AchievementsBinding()),
    GetPage(name: Routes.themes, page: () => const ThemesView(), binding: ThemesBinding()),
    GetPage(name: Routes.settings, page: () => const SettingsView(), binding: SettingsBinding()),
  ];
}
