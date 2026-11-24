import 'dart:async';
import 'package:get/get.dart';
import '../../app/utils/formatters.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/dialogs.dart';
import '../purchase/purchase_flow_controller.dart';

class StoreController extends GetxController {
  PurchaseService get iap => PurchaseService.to;
  ProgressService get progress => ProgressService.to;

  final countdown = ''.obs;
  final freeLeft = 0.obs;
  Timer? _t;

  @override
  void onInit() {
    super.onInit();
    freeLeft.value = AdsService.to.rewardedHintsLeftToday;
    _tick();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    if (!iap.productsLoaded.value && iap.storeAvailable.value) iap.loadProducts();
  }

  void _tick() => countdown.value = Fmt.countdown(progress.starterOfferRemaining);

  void buy(String id) => PurchaseFlowController.to.buy(id);
  void restore() => PurchaseFlowController.to.restore();

  Future<void> freeHint() async {
    if (freeLeft.value <= 0) return;
    final earned = await Dialogs.watchRewarded();
    if (!earned) return;
    progress.addHints(1);
    AdsService.to.noteRewardedHint();
    freeLeft.value = AdsService.to.rewardedHintsLeftToday;
    Dialogs.toast('+1 hint added');
  }

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}
