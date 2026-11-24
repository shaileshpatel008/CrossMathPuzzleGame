/// Small deterministic PRNG (xorshift32). The same seed produces the same
/// puzzle on every device, which keeps journey levels and dailies identical
/// for all players and lets puzzles be regenerated offline.
class Rng {
  Rng(int seed) {
    _s = (seed ^ 0x9E3779B9) & 0xFFFFFFFF;
    if (_s == 0) _s = 0x6D2B79F5;
    for (var i = 0; i < 8; i++) {
      next();
    }
  }

  late int _s;

  int next() {
    var x = _s;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _s = x & 0xFFFFFFFF;
    return _s;
  }

  /// 0 <= n < max
  int nextInt(int max) => max <= 1 ? 0 : next() % max;

  /// Inclusive range. Returns [lo] when the range is empty.
  int range(int lo, int hi) => hi <= lo ? lo : lo + nextInt(hi - lo + 1);

  double nextDouble() => next() / 4294967296.0;

  bool chance(double p) => nextDouble() < p;

  T pick<T>(List<T> list) => list[nextInt(list.length)];

  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }
}
