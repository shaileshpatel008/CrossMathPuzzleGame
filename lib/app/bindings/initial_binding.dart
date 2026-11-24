import 'package:get/get.dart';

import '../../modules/purchase/purchase_flow_controller.dart';

/// App-wide controllers that live for the whole session.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PurchaseFlowController(), permanent: true);
  }
}
