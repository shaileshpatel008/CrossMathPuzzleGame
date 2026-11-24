import 'difficulty.dart';

enum CellKind { empty, number, op, equals }

class PuzzleCell {
  const PuzzleCell(this.kind, {this.value = 0, this.op = ''});
  const PuzzleCell.empty() : this(CellKind.empty);

  final CellKind kind;

  /// Solution value for number cells.
  final int value;

  /// Operator character for operator cells.
  final String op;

  bool get isNumber => kind == CellKind.number;
  bool get isEmpty => kind == CellKind.empty;

  String get text => switch (kind) {
    CellKind.number => '$value',
    CellKind.op => op,
    CellKind.equals => '=',
    CellKind.empty => '',
  };

  Map<String, dynamic> toJson() => {'k': kind.index, 'v': value, 'o': op};
  factory PuzzleCell.fromJson(Map<String, dynamic> j) =>
      PuzzleCell(CellKind.values[j['k'] as int], value: j['v'] as int, op: j['o'] as String);
}

/// One equation: cells in reading order, e.g. [a, op, b, =, c] or
/// [a, op, b, op, c, =, d]. Numbers sit on even positions.
class Equation {
  const Equation(this.cells, this.horizontal);
  final List<int> cells;
  final bool horizontal;

  List<int> get numberCells => [for (var i = 0; i < cells.length; i += 2) cells[i]];
  List<int> get opCells => [for (var i = 1; i < cells.length - 2; i += 2) cells[i]];

  Map<String, dynamic> toJson() => {'c': cells, 'h': horizontal};
  factory Equation.fromJson(Map<String, dynamic> j) => Equation((j['c'] as List).cast<int>(), j['h'] as bool);
}

class Puzzle {
  Puzzle({
    required this.width,
    required this.height,
    required this.cells,
    required this.equations,
    required this.blanks,
    required this.tray,
    required this.difficulty,
    required this.seed,
  }) {
    for (var e = 0; e < equations.length; e++) {
      for (final c in equations[e].cells) {
        (_cellEquations[c] ??= []).add(e);
      }
    }
    _blankSet.addAll(blanks);
  }

  final int width;
  final int height;
  final List<PuzzleCell> cells;
  final List<Equation> equations;

  /// Cell indexes the player must fill.
  final List<int> blanks;

  /// Tile values available to the player (solution values + decoys), sorted.
  final List<int> tray;
  final Difficulty difficulty;
  final int seed;

  final Map<int, List<int>> _cellEquations = {};
  final Set<int> _blankSet = {};

  int row(int index) => index ~/ width;
  int col(int index) => index % width;
  bool isBlank(int index) => _blankSet.contains(index);
  List<int> equationsOf(int index) => _cellEquations[index] ?? const [];

  /// Distinct tray values with their counts.
  Map<int, int> get trayCounts {
    final m = <int, int>{};
    for (final v in tray) {
      m[v] = (m[v] ?? 0) + 1;
    }
    return m;
  }

  Map<String, dynamic> toJson() => {
    'w': width,
    'h': height,
    'cells': cells.map((c) => c.toJson()).toList(),
    'eqs': equations.map((e) => e.toJson()).toList(),
    'blanks': blanks,
    'tray': tray,
    'd': difficulty.name,
    'seed': seed,
  };

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
    width: j['w'] as int,
    height: j['h'] as int,
    cells: (j['cells'] as List).map((e) => PuzzleCell.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    equations: (j['eqs'] as List).map((e) => Equation.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    blanks: (j['blanks'] as List).cast<int>(),
    tray: (j['tray'] as List).cast<int>(),
    difficulty: DifficultyX.tryParse(j['d'] as String) ?? Difficulty.easy,
    seed: j['seed'] as int,
  );
}
