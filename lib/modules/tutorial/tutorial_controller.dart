import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/engine/tutorial_puzzle.dart';
import '../../data/models/game_args.dart';
import '../../data/models/puzzle.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/haptics_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/settings_service.dart';

/// Artboard 04 — guided Level 1 with coach marks.
class TutorialController extends GetxController {
  final Puzzle puzzle = tutorialPuzzle();
  final step = 0.obs; // 0: fill top row, 1: fill corner, 2: done
  final wrongTap = 0.obs;
  final _start = DateTime.now();

  static const targets = [2, 24];
  static const answers = [3, 11];

  /// Cells highlighted for the current step.
  Set<int> get focus => switch (step.value) {
    0 => {0, 1, 2, 3, 4},
    1 => {4, 9, 14, 19, 24, 20, 21, 22, 23},
    _ => <int>{},
  };

  bool isFilled(int cell) =>
      (cell == targets[0] && step.value >= 1) || (cell == targets[1] && step.value >= 2);

  bool tileUsed(int value) => (value == 3 && step.value >= 1) || (value == 11 && step.value >= 2);

  String get tipTitle => const ['Fill the top row', 'Now the last cell', 'Perfect! 3 stars'][step.value];
  String get tip => const [
    '8 − ? = 5. Tap the number that makes this equation true.',
    'It completes two equations at once: 5 + 6 = ? and 4 + 7 = ?',
    'Every row and column is true. Levels get bigger and trickier as you go.',
  ][step.value];

  void tapTile(int value) {
    if (step.value >= 2) return;
    if (value == answers[step.value]) {
      AudioService.to.play(step.value == 1 ? Sfx.win : Sfx.correct);
      HapticsService.to.light();
      step.value++;
    } else {
      AudioService.to.play(Sfx.wrong);
      HapticsService.to.medium();
      wrongTap.value++;
    }
  }

  void finish() {
    SettingsService.to.onboardingDone.value = true;
    final p = ProgressService.to;
    if (p.currentLevel.value == 1) {
      p.completeGame(
        GameArgs.journey(1),
        seconds: DateTime.now().difference(_start).inSeconds,
        mistakes: 0,
        hintsUsed: 0,
        relaxed: false,
      );
    }
    Get.offAllNamed(Routes.home);
  }

  void skip() {
    SettingsService.to.onboardingDone.value = true;
    Get.offAllNamed(Routes.home);
  }
}
