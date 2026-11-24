import 'package:get/get.dart';
import '../../data/models/difficulty.dart';
import '../../data/services/progress_service.dart';

class StatsController extends GetxController {
  /// null = All
  final tab = Rxn<Difficulty>();
  ProgressService get progress => ProgressService.to;

  static const tabs = [
    null,
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
    Difficulty.master,
  ];

  DiffStats get current {
    final d = tab.value;
    if (d == null) return progress.allStats;
    // Tutorial puzzles count under Easy.
    return d == Difficulty.easy
        ? progress.stats(Difficulty.easy) + progress.stats(Difficulty.tutorial)
        : progress.stats(d);
  }
}
