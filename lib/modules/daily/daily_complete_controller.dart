import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/constants/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/utils/formatters.dart';
import '../../data/models/level_result.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/progress_service.dart';

class DailyCompleteController extends GetxController {
  /// Null when opened from the trophy card (cabinet only).
  final LevelResult? result = Get.arguments as LevelResult?;
  ProgressService get progress => ProgressService.to;

  Future<void> backToCalendar() async {
    if (result != null) {
      final removeAds = await AdsService.to.maybeShowInterstitial();
      if (removeAds) {
        Get.offNamed(Routes.store);
        return;
      }
    }
    Get.back();
  }

  void share() {
    final r = result;
    final text = r == null
        ? 'I collect monthly maths trophies in ${AppConstants.shortName}! ${AppConstants.playStoreUrl}'
        : 'I solved the ${Fmt.friendlyDate(r.args.date!)} daily in ${Fmt.time(r.seconds)} '
              '(${r.dailyStreak}-day streak) on ${AppConstants.shortName}! ${AppConstants.playStoreUrl}';
    SharePlus.instance.share(ShareParams(text: text));
  }
}
