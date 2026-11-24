import 'package:get/get.dart';

import 'level_map_controller.dart';

class LevelMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelMapController>(() => LevelMapController());
  }
}
