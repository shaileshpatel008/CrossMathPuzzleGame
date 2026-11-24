import 'package:get/get.dart';

import 'level_complete_controller.dart';

class LevelCompleteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelCompleteController>(() => LevelCompleteController());
  }
}
