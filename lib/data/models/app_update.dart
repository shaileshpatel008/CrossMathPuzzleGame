import '../../app/constants/update_config.dart';

/// Semantic-ish version ("1.2.10", "1.2", "1.2.3+4"). Build suffixes are ignored.
class AppVersion implements Comparable<AppVersion> {
  AppVersion(this.parts);

  factory AppVersion.parse(String v) {
    final core = v.trim().split('+').first.split('-').first;
    final parts = core.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return AppVersion(parts);
  }

  final List<int> parts;

  @override
  int compareTo(AppVersion other) {
    final n = parts.length > other.parts.length ? parts.length : other.parts.length;
    for (var i = 0; i < n; i++) {
      final a = i < parts.length ? parts[i] : 0;
      final b = i < other.parts.length ? other.parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator <(AppVersion o) => compareTo(o) < 0;
  bool operator >(AppVersion o) => compareTo(o) > 0;

  @override
  bool operator ==(Object other) => other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => parts.join('.');
}

enum UpdateDecision { none, optional, force }

/// Pure decision logic (unit-tested in test/update_test.dart).
UpdateDecision decideUpdate({
  required AppVersion current,
  required bool updateAvailable,
  String? latestVersion,
  String? minSupportedVersion,
  int playPriority = 0,
  UpdateMode mode = UpdateConfig.mode,
  String? skippedVersion,
  DateTime? snoozedUntil,
  DateTime? now,
  bool userInitiated = false,
}) {
  final min = minSupportedVersion == null ? null : AppVersion.parse(minSupportedVersion);
  // Below the minimum supported version: always blocking, even if the store
  // hasn't propagated the newest build to this user yet.
  if (min != null && current < min) return UpdateDecision.force;
  if (!updateAvailable) return UpdateDecision.none;
  if (mode == UpdateMode.force || playPriority >= UpdateConfig.forceUpdatePriority) {
    return UpdateDecision.force;
  }
  if (!userInitiated) {
    if (latestVersion != null && skippedVersion == latestVersion) return UpdateDecision.none;
    if (snoozedUntil != null && (now ?? DateTime.now()).isBefore(snoozedUntil)) return UpdateDecision.none;
  }
  return UpdateDecision.optional;
}
