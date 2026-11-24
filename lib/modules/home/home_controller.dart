import 'dart:async';

import 'package:get/get.dart';

import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/utils/formatters.dart';
import '../../data/models/difficulty.dart';
import '../../data/models/game_args.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/update_service.dart';
import '../../widgets/dialogs.dart';
import 'widgets/daily_gift_dialog.dart';
import 'widgets/exit_dialog.dart';
import 'widgets/quick_play_sheet.dart';

class HomeController extends GetxController {
  ProgressService get progress => ProgressService.to;
  PurchaseService get iap => PurchaseService.to;

  final offerCountdown = ''.obs;
  Timer? _ticker;

  static const _askedNotificationsKey = 'asked_notifications';

  int get level => progress.currentLevel.value;
  Difficulty get tier => DifficultyX.forLevel(level);
  int get chapter => ProgressService.chapterOf(level);
  int get levelInChapter => (level - 1) % AppConstants.levelsPerChapter;

  bool get dailyDoneToday => progress.isDailySolved(Fmt.today());

  bool get showStarterOffer => !iap.adsRemoved && progress.starterOfferActive;
  bool get showRemoveAdsPromo => !iap.adsRemoved && !progress.starterOfferActive;

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      offerCountdown.value = Fmt.countdown(progress.starterOfferRemaining);
    });
    offerCountdown.value = Fmt.countdown(progress.starterOfferRemaining);
  }

  @override
  void onReady() {
    super.onReady();
    _onArrive();
  }

  Future<void> _onArrive() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (AdsService.to.isFullScreenShowing) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (progress.giftAvailable && Get.currentRoute == Routes.home) {
      await Get.dialog(const DailyGiftDialog());
    }
    final s = StorageService.to;
    if (!s.readBool(_askedNotificationsKey)) {
      s.write(_askedNotificationsKey, true);
      await NotificationService.to.requestPermission();
      await NotificationService.to.sync();
    }
    // Optional update prompt (Play In-App Updates / App Store), after other popups.
    if (Get.currentRoute == Routes.home) await UpdateService.to.checkOnLaunch();
  }

  void play() {
    if (level == 1) {
      Get.toNamed(Routes.tutorial);
      return;
    }
    Get.toNamed(Routes.game, arguments: GameArgs.journey(level));
  }

  void openQuickPlay() => Dialogs.sheet(const QuickPlaySheet());

  Future<void> onBackPressed() => Get.dialog(const ExitDialog());

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
