import 'package:get/get.dart';

import 'daily_controller.dart';

class DailyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyController>(() => DailyController());
  }
}
