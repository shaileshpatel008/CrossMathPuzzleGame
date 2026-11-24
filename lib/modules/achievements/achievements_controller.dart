import 'package:get/get.dart';
import '../../data/models/achievement.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/progress_service.dart';
import '../../widgets/dialogs.dart';

class AchievementsController extends GetxController {
  ProgressService get progress => ProgressService.to;

  void claim(AchievementDef a) {
    progress.claimAchievement(a);
    AudioService.to.play(Sfx.reward);
    Dialogs.toast('+${a.reward} hints added');
  }
}
