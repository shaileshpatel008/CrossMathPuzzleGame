import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/utils/formatters.dart';
import '../../data/models/game_args.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../widgets/dialogs.dart';

enum DayState { empty, future, today, solved, missed }

/// Artboard 09 — Daily challenge calendar.
class DailyController extends GetxController {
  ProgressService get progress => ProgressService.to;

  final month = DateTime(Fmt.today().year, Fmt.today().month).obs;
  final selected = Fmt.today().obs;

  DateTime get today => Fmt.today();
  DateTime get earliestMonth => DateTime(today.year - 1, today.month);

  bool get canGoBack => month.value.isAfter(earliestMonth);
  bool get canGoForward => month.value.isBefore(DateTime(today.year, today.month));

  void prevMonth() {
    if (canGoBack) month.value = DateTime(month.value.year, month.value.month - 1);
  }

  void nextMonth() {
    if (canGoForward) month.value = DateTime(month.value.year, month.value.month + 1);
  }

  /// Leading blanks (Mon-first) followed by every day of the visible month.
  List<DateTime?> get days {
    final m = month.value;
    final first = DateTime(m.year, m.month, 1);
    final count = DateTime(m.year, m.month + 1, 0).day;
    return [
      for (var i = 1; i < first.weekday; i++) null,
      for (var d = 1; d <= count; d++) DateTime(m.year, m.month, d),
    ];
  }

  DayState state(DateTime? d) {
    if (d == null) return DayState.empty;
    if (d.isAfter(today)) return DayState.future;
    if (progress.isDailySolved(d)) return DayState.solved;
    if (d == today) return DayState.today;
    return DayState.missed;
  }

  void select(DateTime? d) {
    final s = state(d);
    if (s == DayState.empty || s == DayState.future) return;
    selected.value = d!;
  }

  DayState get selectedState => state(selected.value);

  bool get missedUnlocked =>
      PurchaseService.to.isVip || AdsService.to.isDailyUnlocked(Fmt.dateKey(selected.value));

  Future<void> play() async {
    final d = selected.value;
    switch (state(d)) {
      case DayState.today:
        Get.toNamed(Routes.game, arguments: GameArgs.daily(d));
      case DayState.solved:
        Get.toNamed(Routes.game, arguments: GameArgs.daily(d, replay: true));
      case DayState.missed:
        if (!missedUnlocked) {
          final earned = await Dialogs.watchRewarded();
          if (!earned) return;
          AdsService.to.unlockDaily(Fmt.dateKey(d));
        }
        Get.toNamed(Routes.game, arguments: GameArgs.daily(d));
      default:
        break;
    }
  }
}
