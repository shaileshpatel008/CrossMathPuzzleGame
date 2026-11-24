import 'package:crossmath_puzzle/data/engine/evaluator.dart';
import 'package:crossmath_puzzle/data/engine/generator.dart';
import 'package:crossmath_puzzle/data/engine/solver.dart';
import 'package:crossmath_puzzle/data/engine/tutorial_puzzle.dart';
import 'package:crossmath_puzzle/data/models/difficulty.dart';
import 'package:crossmath_puzzle/data/models/game_args.dart';
import 'package:crossmath_puzzle/data/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void _expectValid(Puzzle p, {bool checkRange = true}) {
  for (final e in p.equations) {
    final nums = [for (final c in e.numberCells) p.cells[c].value];
    final ops = [for (final c in e.opCells) p.cells[c].op];
    expect(equationHolds(nums, ops), isTrue, reason: 'equation $nums $ops');
    if (checkRange) {
      for (final n in nums) {
        expect(n, inInclusiveRange(1, p.difficulty.config.maxNumber));
      }
    }
  }
  expect(p.blanks, isNotEmpty);
  final solution = [for (final b in p.blanks) p.cells[b].value]..sort();
  final tray = List<int>.from(p.tray);
  for (final v in solution) {
    expect(tray.remove(v), isTrue, reason: 'tray holds every answer');
  }
  expect(tray.length, p.difficulty.config.decoys);
  expect(countSolutions(p), 1, reason: 'unique solution');
}

void main() {
  test('evaluator follows × ÷ before + −', () {
    expect(evaluateExpression([2, 3, 4], [Ops.add, Ops.mul]), 14);
    expect(evaluateExpression([20, 4, 3], [Ops.div, Ops.sub]), 2);
    expect(evaluateExpression([7, 2], [Ops.div]), isNull);
  });

  test('tutorial puzzle is valid and unique', () => _expectValid(tutorialPuzzle(), checkRange: false));

  for (final d in Difficulty.values) {
    test('generates unique ${d.label} puzzles', () {
      final sw = Stopwatch()..start();
      var blanks = 0, eqs = 0;
      for (var s = 0; s < 40; s++) {
        final p = generatePuzzle(GenerateRequest(d, 1000 + s * 37, s / 39));
        _expectValid(p);
        expect(p.width, lessThanOrEqualTo(d.config.maxWidth));
        blanks += p.blanks.length;
        eqs += p.equations.length;
      }
      // ignore: avoid_print
      print(
        '${d.label}: avg eqs ${(eqs / 40).toStringAsFixed(1)}, '
        'avg blanks ${(blanks / 40).toStringAsFixed(1)}, ${sw.elapsedMilliseconds ~/ 40} ms/puzzle',
      );
    });
  }

  test('journey generation is deterministic', () {
    final a = GameArgs.journey(128), b = GameArgs.journey(128);
    final p1 = generatePuzzle(GenerateRequest(a.difficulty, a.seed, a.tierProgress));
    final p2 = generatePuzzle(GenerateRequest(b.difficulty, b.seed, b.tierProgress));
    expect(p1.toJson(), p2.toJson());
  });
}
