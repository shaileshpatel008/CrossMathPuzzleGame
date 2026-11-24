import 'package:crossmath_puzzle/app/constants/update_config.dart';
import 'package:crossmath_puzzle/data/models/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 24, 12);
  final v100 = AppVersion.parse('1.0.0');

  test('versions compare numerically, ignoring build numbers', () {
    expect(AppVersion.parse('1.0.10') > AppVersion.parse('1.0.9'), isTrue);
    expect(AppVersion.parse('1.2'), AppVersion.parse('1.2.0'));
    expect(AppVersion.parse('1.0.1+7'), AppVersion.parse('1.0.1'));
    expect(AppVersion.parse('2.0.0') > AppVersion.parse('1.99.99'), isTrue);
  });

  test('no update available -> nothing', () {
    expect(decideUpdate(current: v100, updateAvailable: false), UpdateDecision.none);
  });

  test('update available -> optional by default', () {
    expect(
      decideUpdate(current: v100, updateAvailable: true, latestVersion: '1.1.0', now: now),
      UpdateDecision.optional,
    );
  });

  test('"Later" snoozes automatic prompts but not a manual check', () {
    final until = now.add(const Duration(days: 3));
    expect(
      decideUpdate(current: v100, updateAvailable: true, snoozedUntil: until, now: now),
      UpdateDecision.none,
    );
    expect(
      decideUpdate(current: v100, updateAvailable: true, snoozedUntil: until, now: now, userInitiated: true),
      UpdateDecision.optional,
    );
    expect(
      decideUpdate(
        current: v100,
        updateAvailable: true,
        snoozedUntil: until,
        now: until.add(const Duration(minutes: 1)),
      ),
      UpdateDecision.optional,
    );
  });

  test('"Skip this version" hides only that version', () {
    expect(
      decideUpdate(current: v100, updateAvailable: true, latestVersion: '1.1.0', skippedVersion: '1.1.0'),
      UpdateDecision.none,
    );
    expect(
      decideUpdate(current: v100, updateAvailable: true, latestVersion: '1.2.0', skippedVersion: '1.1.0'),
      UpdateDecision.optional,
    );
  });

  test('below min supported version -> forced, even when snoozed or skipped', () {
    expect(
      decideUpdate(
        current: v100,
        updateAvailable: true,
        latestVersion: '1.1.0',
        minSupportedVersion: '1.0.1',
        skippedVersion: '1.1.0',
        snoozedUntil: now.add(const Duration(days: 3)),
        now: now,
      ),
      UpdateDecision.force,
    );
    expect(
      decideUpdate(current: v100, updateAvailable: false, minSupportedVersion: '1.0.1'),
      UpdateDecision.force,
    );
    expect(
      decideUpdate(current: v100, updateAvailable: true, minSupportedVersion: '1.0.0'),
      UpdateDecision.optional,
    );
  });

  test('high Play update priority or force mode -> forced', () {
    expect(
      decideUpdate(current: v100, updateAvailable: true, playPriority: UpdateConfig.forceUpdatePriority),
      UpdateDecision.force,
    );
    expect(decideUpdate(current: v100, updateAvailable: true, mode: UpdateMode.force), UpdateDecision.force);
  });
}
