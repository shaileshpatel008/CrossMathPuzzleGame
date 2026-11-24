import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/dialogs.dart';

/// App-wide purchase UX: shows "Connecting…", hands over to the Google Play
/// sheet, then routes every outcome to the right screen:
/// success → Purchase success, pending / failed / restored / nothing → status.
class PurchaseFlowController extends GetxController {
  static PurchaseFlowController get to => Get.find();

  StreamSubscription<PurchaseEvent>? _sub;
  Timer? _timeout;

  @override
  void onInit() {
    super.onInit();
    _sub = PurchaseService.to.events.listen(_onEvent);
  }

  Future<void> buy(String productId) async {
    if (PurchaseService.to.busy.value) return;
    AdsService.to.suppressAppOpen = true;
    Dialogs.showConnecting();
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 90), _done);
    final launched = await PurchaseService.to.buy(productId);
    if (!launched) _done();
  }

  Future<void> restore() async {
    AdsService.to.suppressAppOpen = true;
    Dialogs.showConnecting();
    await PurchaseService.to.restore();
  }

  void _done() {
    _timeout?.cancel();
    Dialogs.hideConnecting();
    AdsService.to.suppressAppOpen = false;
  }

  void _onEvent(PurchaseEvent e) {
    _done();
    switch (e.type) {
      case PurchaseEventType.success:
        Get.toNamed(Routes.purchaseSuccess, arguments: e.productId);
      case PurchaseEventType.pending:
        Get.toNamed(Routes.purchaseStatus, arguments: {'state': 'pending', 'product': e.productId});
      case PurchaseEventType.failed:
        Get.toNamed(Routes.purchaseStatus, arguments: {'state': 'failed', 'message': e.message});
      case PurchaseEventType.cancelled:
        Dialogs.toast('Purchase cancelled — you were not charged.');
      case PurchaseEventType.restored:
        Get.toNamed(Routes.purchaseStatus, arguments: {'state': 'restored', 'restored': e.restoredIds});
      case PurchaseEventType.nothingToRestore:
        Get.toNamed(Routes.purchaseStatus, arguments: {'state': 'none'});
      case PurchaseEventType.unavailable:
        Dialogs.info(
          'Store unavailable',
          e.message ?? 'Google Play is not available right now. Please try again later.',
        );
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _timeout?.cancel();
    super.onClose();
  }
}
