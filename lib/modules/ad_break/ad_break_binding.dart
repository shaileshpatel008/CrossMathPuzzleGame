import 'package:get/get.dart';

import 'ad_break_controller.dart';

class AdBreakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdBreakController>(() => AdBreakController());
  }
}
