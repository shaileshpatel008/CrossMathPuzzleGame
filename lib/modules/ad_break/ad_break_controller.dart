import 'dart:async';
import 'package:get/get.dart';
import '../../data/services/ads_service.dart';

class AdBreakController extends GetxController {
  final countdown = 2.obs;
  Timer? _t;
  bool _done = false;

  @override
  void onReady() {
    super.onReady();
    _t = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (countdown.value > 1) {
        countdown.value--;
        return;
      }
      t.cancel();
      await _showAd();
    });
  }

  Future<void> _showAd() async {
    if (_done) return;
    _done = true;
    await AdsService.to.showInterstitialNow();
    Get.back(result: 'done');
  }

  void removeAds() {
    if (_done) return;
    _done = true;
    _t?.cancel();
    Get.back(result: 'remove_ads');
  }

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}
