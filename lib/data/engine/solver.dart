import '../models/puzzle.dart';
import 'evaluator.dart';

/// Counts solutions of a puzzle given its tray (up to [limit]).
///
/// Used by the generator to guarantee every puzzle has exactly one answer.
/// If the search exceeds [nodeLimit] it reports [limit] (treated as
/// "not provably unique") so the generator reveals another cell.
int countSolutions(Puzzle p, {int limit = 2, int nodeLimit = 60000}) {
  final s = _Solver(p, limit, nodeLimit);
  s.run();
  return s.aborted ? limit : s.solutions;
}

class _Solver {
  _Solver(this.p, this.limit, this.nodeLimit) {
    values = List<int>.filled(p.cells.length, 0);
    for (var i = 0; i < p.cells.length; i++) {
      if (p.cells[i].isNumber && !p.isBlank(i)) values[i] = p.cells[i].value;
    }
    for (final v in p.tray) {
      remaining[v] = (remaining[v] ?? 0) + 1;
    }
    for (final e in p.equations) {
      eqNums.add(e.numberCells);
      eqOps.add([for (final c in e.opCells) p.cells[c].op]);
    }
  }

  final Puzzle p;
  final int limit;
  final int nodeLimit;
  late final List<int> values;
  final Map<int, int> remaining = {};
  final List<List<int>> eqNums = [];
  final List<List<String>> eqOps = [];
  int solutions = 0;
  int nodes = 0;
  bool aborted = false;

  void run() => _search();

  bool _consistent(int cell) {
    for (final e in p.equationsOf(cell)) {
      final cells = eqNums[e];
      final nums = <int>[];
      var complete = true;
      for (final c in cells) {
        final v = values[c];
        if (v == 0) {
          complete = false;
          break;
        }
        nums.add(v);
      }
      if (complete && !equationHolds(nums, eqOps[e])) return false;
    }
    return true;
  }

  void _search() {
    if (aborted || solutions >= limit) return;
    if (++nodes > nodeLimit) {
      aborted = true;
      return;
    }
    // Most-constrained equation first: the one with the fewest unknowns.
    var bestCell = -1;
    var bestUnknown = 1 << 30;
    for (final cells in eqNums) {
      var unknown = 0;
      var firstUnknown = -1;
      for (final c in cells) {
        if (values[c] == 0) {
          unknown++;
          if (firstUnknown < 0) firstUnknown = c;
        }
      }
      if (unknown > 0 && unknown < bestUnknown) {
        bestUnknown = unknown;
        bestCell = firstUnknown;
        if (unknown == 1) break;
      }
    }
    if (bestCell < 0) {
      solutions++;
      return;
    }
    final candidates = remaining.keys.where((k) => remaining[k]! > 0).toList();
    for (final v in candidates) {
      values[bestCell] = v;
      remaining[v] = remaining[v]! - 1;
      if (_consistent(bestCell)) _search();
      remaining[v] = remaining[v]! + 1;
      values[bestCell] = 0;
      if (aborted || solutions >= limit) return;
    }
  }
}
