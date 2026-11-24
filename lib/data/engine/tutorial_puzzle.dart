import '../models/difficulty.dart';
import '../models/puzzle.dart';

/// Level 1: the hand-made guided puzzle (see artboard "04 Guided first level").
///
///   8 − 3 = 5
///   ÷   +   +
///   2 + 4 = 6
///   =   =   =
///   4 + 7 = 11
///
/// Blanks: the "3" (row 1) and the "11" (bottom-right).
Puzzle tutorialPuzzle() {
  const rows = [
    ['8', Ops.sub, '3', '=', '5'],
    [Ops.div, '', Ops.add, '', Ops.add],
    ['2', Ops.add, '4', '=', '6'],
    ['=', '', '=', '', '='],
    ['4', Ops.add, '7', '=', '11'],
  ];
  final cells = <PuzzleCell>[];
  for (final r in rows) {
    for (final t in r) {
      if (t.isEmpty) {
        cells.add(const PuzzleCell.empty());
      } else if (t == '=') {
        cells.add(const PuzzleCell(CellKind.equals));
      } else if (int.tryParse(t) != null) {
        cells.add(PuzzleCell(CellKind.number, value: int.parse(t)));
      } else {
        cells.add(PuzzleCell(CellKind.op, op: t));
      }
    }
  }
  return Puzzle(
    width: 5,
    height: 5,
    cells: cells,
    equations: const [
      Equation([0, 1, 2, 3, 4], true),
      Equation([10, 11, 12, 13, 14], true),
      Equation([20, 21, 22, 23, 24], true),
      Equation([0, 5, 10, 15, 20], false),
      Equation([2, 7, 12, 17, 22], false),
      Equation([4, 9, 14, 19, 24], false),
    ],
    blanks: const [2, 24],
    tray: const [3, 11],
    difficulty: Difficulty.tutorial,
    seed: 1,
  );
}
