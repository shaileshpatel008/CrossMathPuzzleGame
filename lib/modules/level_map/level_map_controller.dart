import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../data/models/game_args.dart';
import '../../data/services/progress_service.dart';

class LevelMapController extends GetxController {
  ProgressService get progress => ProgressService.to;
  final expanded = <int>{}.obs;

  int get currentChapter => ProgressService.chapterOf(progress.currentLevel.value);

  @override
  void onInit() {
    super.onInit();
    expanded.add(currentChapter);
  }

  void toggle(int chapter) {
    if (!expanded.remove(chapter)) expanded.add(chapter);
  }

  void openLevel(int level) {
    final current = progress.currentLevel.value;
    if (level > current) return;
    if (level == 1) {
      Get.toNamed(Routes.tutorial);
      return;
    }
    Get.toNamed(Routes.game, arguments: GameArgs.journey(level, replay: level < current));
  }
}
