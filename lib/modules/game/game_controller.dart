import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/game_themes.dart';
import '../../data/engine/generator.dart';
import '../../data/engine/tutorial_puzzle.dart';
import '../../data/models/difficulty.dart';
import '../../data/models/game_args.dart';
import '../../data/models/puzzle.dart';
import '../../data/services/ads_service.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/haptics_service.dart';
import '../../data/services/progress_service.dart';
import '../../data/services/purchase_service.dart';
import '../../data/services/settings_service.dart';
import '../../widgets/dialogs.dart';
import 'widgets/game_dialogs.dart';

class _Move {
  const _Move(this.cell, this.previous);
  final int cell;
  final int? previous;
}

/// Artboard 11 — the playable board.
class GameController extends GetxController with WidgetsBindingObserver {
  late final GameArgs args = Get.arguments as GameArgs;

  ProgressService get progress => ProgressService.to;
  SettingsService get settings => SettingsService.to;
  PurchaseService get iap => PurchaseService.to;

  final loading = true.obs;
  final puzzle = Rxn<Puzzle>();
  final placed = <int, int>{}.obs; // cell -> placed value
  final selected = RxnInt();
  final mistakes = 0.obs;
  final hintsUsed = 0.obs;
  final seconds = 0.obs;
  final paused = false.obs;
  final finished = false.obs;
  final wrongCells = <int>{}.obs;
  final flashCells = <int>{}.obs;
  final shakeTick = 0.obs;
  final shakeCell = RxnInt();

  bool secondChanceUsed = false;
  final List<_Move> _history = [];
  Map<int, int> _totals = {};
  List<int> trayValues = [];
  Timer? _timer;
  bool _dialogOpen = false;

  Puzzle get p => puzzle.value!;
  Difficulty get difficulty => args.difficulty;
  GameTheme get theme => GameTheme.byId(settings.themeId.value);
  bool get relaxed => settings.relaxedMode.value;
  bool get autoCheck => settings.autoCheck.value && !difficulty.config.forceAutoCheckOff;
  int get mistakeLimit => relaxed ? 0 : difficulty.config.mistakeLimit;
  bool get isVip => iap.isVip;

  String get title => args.title;
  String get subtitle =>
      args.mode == GameMode.journey && args.level == 1 ? 'TUTORIAL' : difficulty.label.toUpperCase();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  // ------------------------------------------------------------------ setup

  Future<void> _load() async {
    final saved = progress.loadGame(args.key);
    final seed = (args.mode == GameMode.quick && saved != null)
        ? (saved['seed'] as int? ?? args.seed)
        : args.seed;
    Puzzle puz;
    if (args.mode == GameMode.journey && args.level == 1) {
      puz = tutorialPuzzle();
    } else {
      puz = await compute(generatePuzzle, GenerateRequest(difficulty, seed, args.tierProgress));
    }
    puzzle.value = puz;
    _totals = puz.trayCounts;
    trayValues = _totals.keys.toList()..sort();

    if (saved != null && saved['seed'] == puz.seed) {
      final m = Map<String, dynamic>.from(saved['placed'] as Map? ?? {});
      placed.assignAll(m.map((k, v) => MapEntry(int.parse(k), (v as num).toInt())));
      mistakes.value = saved['mistakes'] as int? ?? 0;
      hintsUsed.value = saved['hints'] as int? ?? 0;
      seconds.value = saved['seconds'] as int? ?? 0;
      secondChanceUsed = saved['second'] as bool? ?? false;
      wrongCells.assignAll((saved['wrong'] as List? ?? []).cast<int>());
    } else {
      progress.recordStart(difficulty);
    }
    selected.value = _nextOpen(-1);
    loading.value = false;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (loading.value || paused.value || finished.value || _dialogOpen) return;
      seconds.value++;
      if (seconds.value % 10 == 0) _save();
    });
  }

  void _save() {
    if (puzzle.value == null || finished.value) return;
    progress.saveGame(args.key, {
      'seed': p.seed,
      'placed': placed.map((k, v) => MapEntry('$k', v)),
      'mistakes': mistakes.value,
      'hints': hintsUsed.value,
      'seconds': seconds.value,
      'second': secondChanceUsed,
      'wrong': wrongCells.toList(),
    });
  }

  // ---------------------------------------------------------------- helpers

  int solution(int cell) => p.cells[cell].value;
  bool isCorrect(int cell) => placed[cell] == solution(cell);

  int remaining(int value) {
    final used = placed.values.where((v) => v == value).length;
    return (_totals[value] ?? 0) - used;
  }

  /// Next blank (after [from]) that is empty, or not correct when auto-check is on.
  int? _nextOpen(int from) {
    bool open(int c) => !placed.containsKey(c) || (autoCheck && !isCorrect(c));
    for (final c in p.blanks) {
      if (c > from && open(c)) return c;
    }
    for (final c in p.blanks) {
      if (open(c)) return c;
    }
    return null;
  }

  /// Cells of equations passing through the selected cell (highlighted).
  Set<int> get highlighted {
    final s = selected.value;
    if (s == null || puzzle.value == null) return const {};
    return {for (final e in p.equationsOf(s)) ...p.equations[e].cells};
  }

  // ----------------------------------------------------------- interaction

  void tapCell(int cell) {
    if (finished.value || paused.value || !p.isBlank(cell)) return;
    selected.value = cell;
    HapticsService.to.tap();
    AudioService.to.play(Sfx.tap);
  }

  void tapTile(int value) {
    if (finished.value || paused.value) return;
    selected.value ??= _nextOpen(-1);
    final cell = selected.value;
    if (cell == null || remaining(value) <= 0) return;
    if (placed[cell] == value) return;

    _history.add(_Move(cell, placed[cell]));
    placed[cell] = value;
    wrongCells.remove(cell);
    AudioService.to.play(Sfx.place);

    if (autoCheck) {
      if (value != solution(cell)) {
        _registerMistake([cell]);
        _save();
        return;
      }
      HapticsService.to.light();
      _celebrateEquations(cell);
    } else {
      HapticsService.to.tap();
    }
    selected.value = _nextOpen(cell);
    _save();
    _checkComplete();
  }

  void erase() {
    final cell = selected.value;
    if (cell == null || !placed.containsKey(cell) || finished.value) return;
    if (autoCheck && isCorrect(cell)) return; // locked once correct
    _history.add(_Move(cell, placed[cell]));
    placed.remove(cell);
    wrongCells.remove(cell);
    HapticsService.to.tap();
    _save();
  }

  void undo() {
    if (_history.isEmpty || finished.value) return;
    final m = _history.removeLast();
    if (m.previous == null) {
      placed.remove(m.cell);
    } else {
      placed[m.cell] = m.previous!;
    }
    wrongCells.remove(m.cell);
    if (autoCheck && placed.containsKey(m.cell) && !isCorrect(m.cell)) wrongCells.add(m.cell);
    selected.value = m.cell;
    HapticsService.to.tap();
    _save();
  }

  Future<void> hint() async {
    if (finished.value) return;
    if (!isVip && progress.hints.value <= 0) {
      await _withDialog(() => Dialogs.sheet(const OutOfHintsSheet()));
      return;
    }
    final s = selected.value;
    final target = (s != null && !isCorrect(s)) ? s : p.blanks.where((c) => !isCorrect(c)).firstOrNull;
    if (target == null) return;
    final value = solution(target);
    if (remaining(value) <= 0) {
      // Free the tile from a wrongly-placed cell.
      final other = placed.entries.where((e) => e.value == value && !isCorrect(e.key)).firstOrNull;
      if (other != null) {
        placed.remove(other.key);
        wrongCells.remove(other.key);
      }
    }
    if (remaining(value) <= 0) return;
    if (!isVip) progress.spendHint();
    hintsUsed.value++;
    _history.clear();
    placed[target] = value;
    wrongCells.remove(target);
    AudioService.to.play(Sfx.hint);
    HapticsService.to.light();
    _celebrateEquations(target);
    selected.value = _nextOpen(target);
    _save();
    _checkComplete();
  }

  void _celebrateEquations(int cell) {
    for (final e in p.equationsOf(cell)) {
      final eq = p.equations[e];
      final solved = eq.numberCells.every((c) => !p.isBlank(c) || isCorrect(c));
      if (solved) {
        flashCells.addAll(eq.cells);
        AudioService.to.play(Sfx.equation);
        Future<void>.delayed(const Duration(milliseconds: 650), () => flashCells.removeAll(eq.cells));
      }
    }
  }

  void _registerMistake(List<int> cells) {
    mistakes.value++;
    wrongCells.addAll(cells);
    shakeCell.value = cells.first;
    shakeTick.value++;
    AudioService.to.play(Sfx.wrong);
    HapticsService.to.medium();
    if (mistakeLimit > 0 && mistakes.value >= mistakeLimit) {
      Future<void>.delayed(const Duration(milliseconds: 450), _gameOver);
    }
  }

  void _checkComplete() {
    if (!p.blanks.every(placed.containsKey)) return;
    final wrong = p.blanks.where((c) => !isCorrect(c)).toList();
    if (wrong.isEmpty) {
      _win();
    } else if (!autoCheck) {
      Dialogs.toast(
        '${wrong.length} number${wrong.length == 1 ? ' is' : 's are'} wrong',
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFFF6B6B),
      );
      _registerMistake(wrong);
    }
  }

  // ------------------------------------------------------------ pause & over

  Future<T?> _withDialog<T>(Future<T?> Function() open) async {
    _dialogOpen = true;
    try {
      return await open();
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> pause() async {
    if (finished.value || loading.value) return;
    paused.value = true;
    _save();
    final r = await _withDialog(
      () => Get.dialog<String>(PauseDialog(controller: this), barrierDismissible: false),
    );
    paused.value = false;
    switch (r) {
      case 'restart':
        restart();
      case 'home':
        Get.until((route) => route.settings.name == Routes.home || route.isFirst);
      case 'howto':
        await Get.toNamed(Routes.onboarding, arguments: 'fromGame');
    }
  }

  void restart() {
    placed.clear();
    wrongCells.clear();
    flashCells.clear();
    mistakes.value = 0;
    hintsUsed.value = 0;
    seconds.value = 0;
    secondChanceUsed = false;
    _history.clear();
    finished.value = false;
    progress.clearGame();
    progress.recordStart(difficulty);
    selected.value = _nextOpen(-1);
  }

  Future<void> _gameOver() async {
    if (finished.value) return;
    final r = await _withDialog(
      () => Get.dialog<String>(GameOverDialog(controller: this), barrierDismissible: false),
    );
    switch (r) {
      case 'continue':
        _continueAfterMistakes();
      case 'restart':
        restart();
      default:
        progress.clearGame();
        Get.until((route) => route.settings.name == Routes.home || route.isFirst);
    }
  }

  /// Second chance: removes the wrong numbers and the last mistake.
  void _continueAfterMistakes() {
    secondChanceUsed = true;
    mistakes.value = (mistakeLimit - 1).clamp(0, 99);
    for (final c in wrongCells.toList()) {
      placed.remove(c);
    }
    wrongCells.clear();
    selected.value = _nextOpen(-1);
    _save();
  }

  Future<void> useSecondChance() async {
    if (isVip) {
      Get.back(result: 'continue');
      return;
    }
    final earned = await Dialogs.watchRewarded();
    if (earned) Get.back(result: 'continue');
  }

  Future<void> _win() async {
    finished.value = true;
    _timer?.cancel();
    selected.value = null;
    AudioService.to.play(Sfx.win);
    HapticsService.to.heavy();
    progress.clearGame();
    flashCells.addAll([
      for (var i = 0; i < p.cells.length; i++)
        if (!p.cells[i].isEmpty) i,
    ]);
    final result = progress.completeGame(
      args,
      seconds: seconds.value,
      mistakes: mistakes.value,
      hintsUsed: hintsUsed.value,
      relaxed: relaxed,
    );
    AdsService.to.onPuzzleCompleted();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    Get.offNamed(
      args.mode == GameMode.daily ? Routes.dailyComplete : Routes.levelComplete,
      arguments: result,
    );
  }

  void leave() {
    _save();
    Get.back();
  }

  // ------------------------------------------------------------ lifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _save();
      paused.value = true;
    } else if (state == AppLifecycleState.resumed && !_dialogOpen) {
      paused.value = false;
    }
  }

  @override
  void onClose() {
    _save();
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
