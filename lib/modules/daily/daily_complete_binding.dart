import 'package:get/get.dart';

import 'daily_complete_controller.dart';

class DailyCompleteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyCompleteController>(() => DailyCompleteController());
  }
}
