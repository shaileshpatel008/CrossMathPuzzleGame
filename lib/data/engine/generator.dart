import '../models/difficulty.dart';
import '../models/puzzle.dart';
import 'evaluator.dart';
import 'rng.dart';
import 'solver.dart';

/// Input for [generatePuzzle]; plain data so it can cross isolates.
class GenerateRequest {
  const GenerateRequest(this.difficulty, this.seed, this.progress);
  final Difficulty difficulty;
  final int seed;

  /// 0..1 position inside the tier — more equations / blanks as it rises.
  final double progress;
}

/// Builds a crossword-style maths puzzle:
///  1. lays out equations that cross on shared number cells,
///  2. fills them with valid numbers (whole-number division only),
///  3. blanks out cells and keeps revealing until the solver proves the
///     answer is unique for the given tray.
Puzzle generatePuzzle(GenerateRequest req) {
  final cfg = req.difficulty.config;
  final rng = Rng(req.seed);
  final progress = req.progress.clamp(0.0, 1.0);
  final target =
      cfg.minEquations +
      ((cfg.maxEquations - cfg.minEquations) * progress).round() +
      (rng.chance(0.3) ? 1 : 0);

  _Layout? best;
  for (var attempt = 0; attempt < 40; attempt++) {
    final layout = _Layout(cfg.maxWidth, cfg.maxHeight, cfg, rng)..build(target);
    if (layout.eqs.isEmpty) continue;
    if (best == null || layout.eqs.length > best.eqs.length) best = layout;
    if (best.eqs.length >= target) break;
  }
  return _finish(best!.crop(), cfg, rng, req);
}

// ---------------------------------------------------------------------------

class _G {
  _G(this.kind, {this.value = 0, this.op = ''});
  final CellKind kind;
  final int value;
  final String op;
  bool h = false;
  bool v = false;
}

class _E {
  _E(this.cells, this.horizontal);
  final List<int> cells;
  final bool horizontal;
}

class _Cropped {
  _Cropped(this.w, this.h, this.cells, this.eqs);
  final int w;
  final int h;
  final List<PuzzleCell> cells;
  final List<Equation> eqs;
}

class _Layout {
  _Layout(this.w, this.h, this.cfg, this.rng) : grid = List<_G?>.filled(w * h, null);

  final int w;
  final int h;
  final DifficultyConfig cfg;
  final Rng rng;
  final List<_G?> grid;
  final List<_E> eqs = [];

  int _len() => (cfg.longEquationChance > 0 && rng.chance(cfg.longEquationChance)) ? 7 : 5;

  void build(int target) {
    // First equation, roughly centred.
    for (var t = 0; t < 20 && eqs.isEmpty; t++) {
      var len = _len();
      final horizontal = rng.chance(0.5);
      if ((horizontal ? w : h) < len) len = 5;
      final span = horizontal ? w : h;
      final across = horizontal ? h : w;
      final a = (across ~/ 2 + rng.range(-1, 1)).clamp(0, across - 1);
      final b = rng.range(0, span - len);
      final r0 = horizontal ? a : b;
      final c0 = horizontal ? b : a;
      final vals = _values(len, const {});
      if (vals == null) continue;
      _write(_cells(r0, c0, horizontal, len)!, horizontal, vals);
    }

    var attempts = 0;
    while (eqs.length < target && attempts < 400) {
      attempts++;
      final anchors = <int>[];
      for (var i = 0; i < grid.length; i++) {
        final g = grid[i];
        if (g != null && g.kind == CellKind.number && (g.h != g.v)) anchors.add(i);
      }
      if (anchors.isEmpty) break;
      final anchor = rng.pick(anchors);
      final ag = grid[anchor]!;
      final horizontal = !ag.h; // perpendicular to its existing equation
      final len = _len();
      final ks = <int>[for (var k = 0; k < len; k += 2) k];
      if (len == 7) ks.remove(6); // long equations: anchor is an operand
      rng.shuffle(ks);
      final ar = anchor ~/ w, ac = anchor % w;
      for (final k in ks) {
        final r0 = horizontal ? ar : ar - k;
        final c0 = horizontal ? ac - k : ac;
        final cells = _cells(r0, c0, horizontal, len);
        if (cells == null) continue;
        final fixed = _fit(cells, horizontal, r0, c0, len);
        if (fixed == null || fixed.isEmpty) continue;
        if (fixed.length > (len == 5 ? 2 : 1)) continue;
        final vals = _values(len, fixed);
        if (vals == null) continue;
        _write(cells, horizontal, vals);
        break;
      }
    }
  }

  List<int>? _cells(int r0, int c0, bool horizontal, int len) {
    final out = <int>[];
    for (var i = 0; i < len; i++) {
      final r = horizontal ? r0 : r0 + i;
      final c = horizontal ? c0 + i : c0;
      if (r < 0 || c < 0 || r >= h || c >= w) return null;
      out.add(r * w + c);
    }
    return out;
  }

  bool _occupied(int r, int c) => r >= 0 && c >= 0 && r < h && c < w && grid[r * w + c] != null;

  /// Returns slot→value for existing cells the equation would reuse, or null if it doesn't fit.
  Map<int, int>? _fit(List<int> cells, bool horizontal, int r0, int c0, int len) {
    final dr = horizontal ? 0 : 1, dc = horizontal ? 1 : 0;
    if (_occupied(r0 - dr, c0 - dc)) return null;
    if (_occupied(r0 + dr * len, c0 + dc * len)) return null;
    final fixed = <int, int>{};
    for (var i = 0; i < len; i++) {
      final idx = cells[i];
      final g = grid[idx];
      final r = idx ~/ w, c = idx % w;
      if (g != null) {
        if (g.kind != CellKind.number || i.isOdd) return null;
        if (horizontal ? g.h : g.v) return null;
        fixed[i ~/ 2] = g.value;
      } else {
        // Perpendicular neighbours must be free so equations never touch.
        if (_occupied(r - dc, c - dr) || _occupied(r + dc, c + dr)) return null;
      }
    }
    return fixed;
  }

  void _write(List<int> cells, bool horizontal, ({List<int> nums, List<String> ops}) vals) {
    final len = cells.length;
    for (var i = 0; i < len; i++) {
      final idx = cells[i];
      var g = grid[idx];
      if (g == null) {
        if (i.isEven) {
          g = _G(CellKind.number, value: vals.nums[i ~/ 2]);
        } else if (i == len - 2) {
          g = _G(CellKind.equals);
        } else {
          g = _G(CellKind.op, op: vals.ops[(i - 1) ~/ 2]);
        }
        grid[idx] = g;
      }
      if (horizontal) {
        g.h = true;
      } else {
        g.v = true;
      }
    }
    eqs.add(_E(cells, horizontal));
  }

  // ---- values ----

  ({List<int> nums, List<String> ops})? _values(int len, Map<int, int> fixed) {
    return len == 5 ? _values5(fixed) : _values7(fixed);
  }

  bool _ok(int v) => v >= 1 && v <= cfg.maxNumber;

  ({List<int> nums, List<String> ops})? _values5(Map<int, int> fixed) {
    final ops = List<String>.from(cfg.ops);
    rng.shuffle(ops);
    // Favour the harder operators a little when they are available.
    if (ops.length > 2 && rng.chance(0.45)) {
      ops.sort((a, b) => (a == Ops.add || a == Ops.sub ? 1 : 0) - (b == Ops.add || b == Ops.sub ? 1 : 0));
    }
    for (final op in ops) {
      for (var t = 0; t < 8; t++) {
        List<int>? n;
        if (fixed.length >= 2) {
          n = _third(op, fixed);
        } else if (fixed.length == 1) {
          final e = fixed.entries.first;
          n = _two(op, e.key, e.value);
        } else {
          n = _two(op, 2, rng.range(4, cfg.maxNumber));
        }
        if (n != null && n.every(_ok) && equationHolds(n, [op]) && _interesting(op, n)) {
          return (nums: n, ops: [op]);
        }
        if (fixed.length >= 2) break;
      }
    }
    return null;
  }

  bool _interesting(String op, List<int> n) {
    if ((op == Ops.mul || op == Ops.div) && n[1] < 2) return false;
    if (op == Ops.mul && n[0] < 2) return false;
    return true;
  }

  /// One slot fixed: generate the other two.
  List<int>? _two(String op, int slot, int v) {
    final m = cfg.maxNumber;
    switch (slot) {
      case 2: // result fixed
        switch (op) {
          case Ops.add:
            if (v < 2) return null;
            final a = rng.range(1, v - 1);
            return [a, v - a, v];
          case Ops.sub:
            if (m - v < 1) return null;
            final b = rng.range(1, (m - v).clamp(1, 60));
            return [v + b, b, v];
          case Ops.mul:
            final divs = [
              for (var d = 2; d * 2 <= v; d++)
                if (v % d == 0) d,
            ];
            if (divs.isEmpty) return null;
            final a = rng.pick(divs);
            return [a, v ~/ a, v];
          case Ops.div:
            final maxB = m ~/ v;
            if (maxB < 2) return null;
            final b = rng.range(2, maxB.clamp(2, 12));
            return [v * b, b, v];
        }
      case 0: // left operand fixed
        switch (op) {
          case Ops.add:
            if (m - v < 1) return null;
            final b = rng.range(1, m - v);
            return [v, b, v + b];
          case Ops.sub:
            if (v < 2) return null;
            final b = rng.range(1, v - 1);
            return [v, b, v - b];
          case Ops.mul:
            final maxB = m ~/ v;
            if (v < 2 || maxB < 2) return null;
            final b = rng.range(2, maxB.clamp(2, 12));
            return [v, b, v * b];
          case Ops.div:
            final divs = [
              for (var d = 2; d * 2 <= v; d++)
                if (v % d == 0) d,
            ];
            if (divs.isEmpty) return null;
            final b = rng.pick(divs);
            return [v, b, v ~/ b];
        }
      case 1: // right operand fixed
        switch (op) {
          case Ops.add:
            if (m - v < 1) return null;
            final a = rng.range(1, m - v);
            return [a, v, a + v];
          case Ops.sub:
            if (m - v < 1) return null;
            final c = rng.range(1, (m - v).clamp(1, 60));
            return [c + v, v, c];
          case Ops.mul:
            final maxA = m ~/ v;
            if (v < 2 || maxA < 2) return null;
            final a = rng.range(2, maxA.clamp(2, 12));
            return [a, v, a * v];
          case Ops.div:
            final maxC = m ~/ v;
            if (v < 2 || maxC < 1) return null;
            final c = rng.range(1, maxC.clamp(1, 12));
            return [v * c, v, c];
        }
    }
    return null;
  }

  /// Two slots fixed: the third is determined by the operator.
  List<int>? _third(String op, Map<int, int> f) {
    final a = f[0], b = f[1], c = f[2];
    if (a != null && b != null) {
      final r = evaluateExpression([a, b], [op]);
      return r == null ? null : [a, b, r];
    }
    if (a != null && c != null) {
      switch (op) {
        case Ops.add:
          return [a, c - a, c];
        case Ops.sub:
          return [a, a - c, c];
        case Ops.mul:
          return a != 0 && c % a == 0 ? [a, c ~/ a, c] : null;
        case Ops.div:
          return c != 0 && a % c == 0 ? [a, a ~/ c, c] : null;
      }
    }
    if (b != null && c != null) {
      switch (op) {
        case Ops.add:
          return [c - b, b, c];
        case Ops.sub:
          return [c + b, b, c];
        case Ops.mul:
          return b != 0 && c % b == 0 ? [c ~/ b, b, c] : null;
        case Ops.div:
          return [c * b, b, c];
      }
    }
    return null;
  }

  ({List<int> nums, List<String> ops})? _values7(Map<int, int> fixed) {
    final m = cfg.maxNumber;
    for (var t = 0; t < 400; t++) {
      final o1 = rng.pick(cfg.ops), o2 = rng.pick(cfg.ops);
      final heavy = o1 == Ops.mul || o1 == Ops.div || o2 == Ops.mul || o2 == Ops.div;
      final lim = heavy ? 12.clamp(2, m) : (m ~/ 2).clamp(2, m);
      final n = [rng.range(1, lim), rng.range(2, lim), rng.range(2, lim)];
      fixed.forEach((slot, v) {
        if (slot < 3) n[slot] = v;
      });
      if (o1 == Ops.div && !fixed.containsKey(0) && !fixed.containsKey(1)) {
        n[0] = n[1] * rng.range(1, 9);
      }
      if (o2 == Ops.div && o1 != Ops.mul && o1 != Ops.div && !fixed.containsKey(1) && !fixed.containsKey(2)) {
        n[1] = n[2] * rng.range(1, 9);
      }
      if ((o1 == Ops.mul || o1 == Ops.div) && n[1] < 2) continue;
      if ((o2 == Ops.mul || o2 == Ops.div) && n[2] < 2) continue;
      if (!n.every(_ok)) continue;
      final r = evaluateExpression(n, [o1, o2]);
      if (r == null || !_ok(r)) continue;
      if (fixed.containsKey(3) && fixed[3] != r) continue;
      return (nums: [...n, r], ops: [o1, o2]);
    }
    return null;
  }

  _Cropped crop() {
    var minR = h, maxR = -1, minC = w, maxC = -1;
    for (var i = 0; i < grid.length; i++) {
      if (grid[i] == null) continue;
      final r = i ~/ w, c = i % w;
      if (r < minR) minR = r;
      if (r > maxR) maxR = r;
      if (c < minC) minC = c;
      if (c > maxC) maxC = c;
    }
    final nw = maxC - minC + 1, nh = maxR - minR + 1;
    int map(int i) => (i ~/ w - minR) * nw + (i % w - minC);
    final cells = List<PuzzleCell>.filled(nw * nh, const PuzzleCell.empty());
    for (var i = 0; i < grid.length; i++) {
      final g = grid[i];
      if (g == null) continue;
      cells[map(i)] = PuzzleCell(g.kind, value: g.value, op: g.op);
    }
    final newEqs = [
      for (final e in eqs) Equation([for (final c in e.cells) map(c)], e.horizontal),
    ];
    return _Cropped(nw, nh, cells, newEqs);
  }
}

Puzzle _finish(_Cropped g, DifficultyConfig cfg, Rng rng, GenerateRequest req) {
  final numberCells = [
    for (var i = 0; i < g.cells.length; i++)
      if (g.cells[i].isNumber) i,
  ];
  final cellEqs = <int, List<int>>{};
  final given = <int>[];
  for (var e = 0; e < g.eqs.length; e++) {
    final nums = g.eqs[e].numberCells;
    given.add(nums.length);
    for (final c in nums) {
      (cellEqs[c] ??= []).add(e);
    }
  }

  final progress = req.progress.clamp(0.0, 1.0);
  final ratio = cfg.blankRatioMin + (cfg.blankRatioMax - cfg.blankRatioMin) * progress;
  final target = (numberCells.length * ratio).round().clamp(1, numberCells.length - 1);

  // Harder tiers prefer blanking crossing cells (they constrain two equations).
  final crossBias = 0.1 + 0.4 * progress + (req.difficulty.index >= 3 ? 0.2 : 0);
  final scored = [
    for (final c in numberCells) (c, rng.nextDouble() - ((cellEqs[c]?.length ?? 0) > 1 ? crossBias : 0)),
  ]..sort((a, b) => a.$2.compareTo(b.$2));

  final blanks = <int>[];
  for (final (c, _) in scored) {
    if (blanks.length >= target) break;
    final es = cellEqs[c] ?? const [];
    if (es.every((e) => given[e] > 1)) {
      blanks.add(c);
      for (final e in es) {
        given[e]--;
      }
    }
  }

  final decoys = <int>[];
  for (var i = 0; i < cfg.decoys; i++) {
    final base = g.cells[rng.pick(numberCells)].value;
    final d = (base + rng.range(-3, 3)).clamp(1, cfg.maxNumber);
    decoys.add(d == base ? (d % cfg.maxNumber) + 1 : d);
  }

  Puzzle build() {
    final tray = [for (final b in blanks) g.cells[b].value, ...decoys]..sort();
    return Puzzle(
      width: g.w,
      height: g.h,
      cells: g.cells,
      equations: g.eqs,
      blanks: List<int>.from(blanks)..sort(),
      tray: tray,
      difficulty: req.difficulty,
      seed: req.seed,
    );
  }

  var puzzle = build();
  while (blanks.length > 1 && countSolutions(puzzle) != 1) {
    blanks.removeAt(rng.nextInt(blanks.length));
    puzzle = build();
  }
  return puzzle;
}
