import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/achievement.dart';
import '../../data/models/game_args.dart';
import '../../data/models/level_result.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/progress_service.dart';
import '../../widgets/dialogs.dart';

class LevelCompleteController extends GetxController {
  final LevelResult result = Get.arguments as LevelResult;
  final bonusClaimed = false.obs;
  bool _navigating = false;

  GameArgs get args => result.args;
  bool get isJourney => args.mode == GameMode.journey;

  String get headline => switch (result.stars) {
    3 => 'BRILLIANT!',
    2 => 'GREAT JOB!',
    _ => 'SOLVED!',
  };

  @override
  void onReady() {
    super.onReady();
    for (final id in result.unlockedAchievements) {
      final a = AchievementDef.all.firstWhere((e) => e.id == id);
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        Dialogs.toast(
          'Award unlocked: ${a.title} — claim it in Awards',
          icon: Icons.emoji_events_rounded,
          color: AppColors.gold,
        );
      });
    }
    if (isJourney && !args.replay && ProgressService.to.shouldPromptRate(args.level!)) {
      Future<void>.delayed(const Duration(milliseconds: 1400), Dialogs.rateUs);
    }
  }

  Future<void> claimBonus() async {
    if (bonusClaimed.value || result.rewardHints == 0) return;
    final earned = await Dialogs.watchRewarded();
    if (!earned) return;
    ProgressService.to.addHints(result.rewardHints * 2);
    bonusClaimed.value = true;
    Dialogs.toast('+${result.rewardHints * 2} bonus hints added');
  }

  Future<void> next() async {
    if (_navigating) return;
    _navigating = true;
    final removeAds = await AdsService.to.maybeShowInterstitial(journeyLevel: isJourney ? args.level : null);
    _navigating = false;
    if (removeAds) {
      Get.toNamed(Routes.store);
      return;
    }
    final nextArgs = switch (args.mode) {
      GameMode.journey => GameArgs.journey(ProgressService.to.currentLevel.value),
      GameMode.quick => GameArgs.quick(args.difficulty),
      GameMode.daily => null,
    };
    if (nextArgs == null) {
      Get.back();
    } else {
      Get.offNamed(Routes.game, arguments: nextArgs);
    }
  }

  void replay() => Get.offNamed(
    Routes.game,
    arguments: isJourney ? GameArgs.journey(args.level!, replay: true) : GameArgs.quick(args.difficulty),
  );

  void home() => Get.until((route) => route.settings.name == Routes.home || route.isFirst);
}
