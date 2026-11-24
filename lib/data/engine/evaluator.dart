import '../models/difficulty.dart';

/// Evaluates `n0 op0 n1 op1 n2 ...` with × and ÷ before + and −.
/// Returns null when a division is not exact or a value goes out of bounds.
int? evaluateExpression(List<int> nums, List<String> ops) {
  if (nums.isEmpty || ops.length != nums.length - 1) return null;
  // Pass 1: × and ÷
  final terms = <int>[nums[0]];
  final addOps = <String>[];
  for (var i = 0; i < ops.length; i++) {
    final op = ops[i];
    final n = nums[i + 1];
    if (op == Ops.mul) {
      terms[terms.length - 1] = terms.last * n;
    } else if (op == Ops.div) {
      if (n == 0 || terms.last % n != 0) return null;
      terms[terms.length - 1] = terms.last ~/ n;
    } else {
      terms.add(n);
      addOps.add(op);
    }
  }
  // Pass 2: + and − left to right
  var acc = terms[0];
  for (var i = 0; i < addOps.length; i++) {
    acc = addOps[i] == Ops.add ? acc + terms[i + 1] : acc - terms[i + 1];
  }
  return acc;
}

bool equationHolds(List<int> nums, List<String> ops) {
  // nums = operands..., result
  final value = evaluateExpression(nums.sublist(0, nums.length - 1), ops);
  return value != null && value == nums.last;
}
