import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/constants/app_constants.dart';
import '../../app/constants/storage_keys.dart';
import '../../app/constants/update_config.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/update_dialogs.dart';
import '../models/app_update.dart';
import 'ads_service.dart';
import 'storage_service.dart';

/// Checks for a newer app version and offers it.
///
/// * Android — Google Play In-App Updates: optional = flexible update (downloads
///   in the background while the player keeps playing, then "Restart to update");
///   forced = immediate full-screen update.
/// * iOS — App Store lookup API + our own dialog that opens the App Store
///   (Apple has no in-app update API).
class UpdateService extends GetxService {
  static UpdateService get to => Get.find();

  StorageService get _s => StorageService.to;

  final currentVersion = ''.obs;
  final checking = false.obs;
  bool _dialogOpen = false;
  StreamSubscription<InstallStatus>? _installSub;

  bool get _android => !kIsWeb && Platform.isAndroid;
  bool get _ios => !kIsWeb && Platform.isIOS;

  Future<UpdateService> init() async {
    try {
      currentVersion.value = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return this;
  }

  /// Automatic check (Home). Throttled and respects "Later" / "Skip".
  Future<void> checkOnLaunch() async {
    final last = DateTime.fromMillisecondsSinceEpoch(_s.readInt(StorageKeys.updateLastCheck));
    if (DateTime.now().difference(last) < UpdateConfig.minCheckInterval) {
      // Still finish a flexible update that was downloaded earlier.
      if (_android) await _resumeDownloadedAndroidUpdate();
      return;
    }
    await _check(userInitiated: false);
  }

  /// Settings › Check for updates.
  Future<void> checkNow() => _check(userInitiated: true);

  Future<void> _check({required bool userInitiated}) async {
    if (checking.value || _dialogOpen || currentVersion.value.isEmpty) return;
    checking.value = true;
    _s.write(StorageKeys.updateLastCheck, DateTime.now().millisecondsSinceEpoch);
    try {
      final minSupported = await _fetchMinSupportedVersion();
      if (_android) {
        await _checkAndroid(userInitiated: userInitiated, minSupported: minSupported);
      } else if (_ios) {
        await _checkIos(userInitiated: userInitiated, minSupported: minSupported);
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
      if (userInitiated) Dialogs.toast("Couldn't check for updates. Try again later.");
    } finally {
      checking.value = false;
    }
  }

  // ------------------------------------------------------------------ Android

  Future<void> _checkAndroid({required bool userInitiated, String? minSupported}) async {
    AppUpdateInfo info;
    try {
      info = await InAppUpdate.checkForUpdate();
    } catch (e) {
      // Not installed from Google Play (sideloaded / debug) or Play unavailable.
      debugPrint('In-app update unavailable: $e');
      final decision = decideUpdate(
        current: AppVersion.parse(currentVersion.value),
        updateAvailable: false,
        minSupportedVersion: minSupported,
      );
      if (decision == UpdateDecision.force) {
        await _showDialog(force: true, version: minSupported);
      } else if (userInitiated) {
        Dialogs.info(
          'Updates via Google Play',
          'Install CrossMath Puzzle from Google Play to receive automatic updates.',
        );
      }
      return;
    }

    if (info.installStatus == InstallStatus.downloaded) {
      await _promptRestart();
      return;
    }

    final available =
        info.updateAvailability == UpdateAvailability.updateAvailable ||
        info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress;
    final latestKey = info.availableVersionCode?.toString();
    final decision = decideUpdate(
      current: AppVersion.parse(currentVersion.value),
      updateAvailable: available,
      latestVersion: latestKey,
      minSupportedVersion: minSupported,
      playPriority: info.updatePriority,
      skippedVersion: _s.readString(StorageKeys.updateSkippedVersion),
      snoozedUntil: _snoozedUntil,
      userInitiated: userInitiated,
    );

    switch (decision) {
      case UpdateDecision.none:
        if (userInitiated) Dialogs.toast("You're on the latest version");
      case UpdateDecision.force:
        await _forceAndroid(info);
      case UpdateDecision.optional:
        if (!info.flexibleUpdateAllowed) {
          // Fall back to our own dialog + Play Store link.
          await _showDialog(force: false, version: null, skipKey: latestKey);
          return;
        }
        AdsService.to.suppressAppOpen = true;
        final result = await InAppUpdate.startFlexibleUpdate(); // Play's own consent sheet
        AdsService.to.suppressAppOpen = false;
        if (result == AppUpdateResult.success) {
          _listenForDownload();
        } else if (result == AppUpdateResult.userDeniedUpdate) {
          _snooze();
        }
    }
  }

  Future<void> _forceAndroid(AppUpdateInfo info) async {
    if (info.immediateUpdateAllowed) {
      AdsService.to.suppressAppOpen = true;
      final r = await InAppUpdate.performImmediateUpdate();
      AdsService.to.suppressAppOpen = false;
      if (r == AppUpdateResult.success) return;
    }
    // Declined or not allowed: block with our own dialog (opens the Play Store).
    await _showDialog(force: true, version: null);
  }

  void _listenForDownload() {
    _installSub?.cancel();
    _installSub = InAppUpdate.installUpdateListener.listen((s) {
      if (s == InstallStatus.downloaded) {
        _installSub?.cancel();
        _promptRestart();
      }
    });
    // Some devices finish before the listener attaches — check once more.
    Future<void>.delayed(const Duration(seconds: 2), _resumeDownloadedAndroidUpdate);
  }

  Future<void> _resumeDownloadedAndroidUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.installStatus == InstallStatus.downloaded) await _promptRestart();
    } catch (_) {}
  }

  Future<void> _promptRestart() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final restart = await Get.dialog<bool>(const UpdateReadyDialog());
    _dialogOpen = false;
    if (restart == true) {
      await InAppUpdate.completeFlexibleUpdate(); // installs and relaunches the app
    }
  }

  // ---------------------------------------------------------------------- iOS

  Future<void> _checkIos({required bool userInitiated, String? minSupported}) async {
    final store = await _appStoreLookup();
    final current = AppVersion.parse(currentVersion.value);
    final latest = store?.version;
    final decision = decideUpdate(
      current: current,
      updateAvailable: latest != null && AppVersion.parse(latest) > current,
      latestVersion: latest,
      minSupportedVersion: minSupported,
      skippedVersion: _s.readString(StorageKeys.updateSkippedVersion),
      snoozedUntil: _snoozedUntil,
      userInitiated: userInitiated,
    );
    if (decision == UpdateDecision.none) {
      if (userInitiated) Dialogs.toast("You're on the latest version");
      return;
    }
    await _showDialog(
      force: decision == UpdateDecision.force,
      version: latest ?? minSupported,
      notes: store?.notes,
      storeUrl: store?.url,
      skipKey: latest,
    );
  }

  Future<({String version, String? notes, String? url})?> _appStoreLookup() async {
    final country = (PlatformDispatcher.instance.locale.countryCode ?? 'us').toLowerCase();
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'bundleId': AppConstants.packageName,
      'country': country,
      't': '${DateTime.now().millisecondsSinceEpoch}', // avoid stale CDN responses
    });
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final results = (jsonDecode(res.body) as Map<String, dynamic>)['results'] as List? ?? const [];
    if (results.isEmpty) return null;
    final r = results.first as Map<String, dynamic>;
    final version = r['version'] as String?;
    if (version == null) return null;
    return (version: version, notes: r['releaseNotes'] as String?, url: r['trackViewUrl'] as String?);
  }

  // ------------------------------------------------------------------- shared

  /// Reads `min_supported_version` for this platform from the optional remote JSON.
  Future<String?> _fetchMinSupportedVersion() async {
    final url = UpdateConfig.remoteConfigUrl;
    if (url == null) return null;
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final platform = json[_ios ? 'ios' : 'android'] as Map<String, dynamic>?;
      return platform?['min_supported_version'] as String?;
    } catch (e) {
      debugPrint('Remote update config unavailable: $e');
      return null;
    }
  }

  DateTime? get _snoozedUntil {
    final ms = _s.readInt(StorageKeys.updateSnoozedUntil);
    return ms == 0 ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _snooze() => _s.write(
    StorageKeys.updateSnoozedUntil,
    DateTime.now().add(UpdateConfig.snoozeDuration).millisecondsSinceEpoch,
  );

  Future<void> _showDialog({
    required bool force,
    String? version,
    String? notes,
    String? storeUrl,
    String? skipKey,
  }) async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final r = await Get.dialog<UpdateChoice>(
      UpdateDialog(force: force, version: version, notes: notes, canSkip: skipKey != null),
      barrierDismissible: !force,
    );
    _dialogOpen = false;
    switch (r) {
      case UpdateChoice.update:
        await openStore(storeUrl);
        if (force) {
          // Keep blocking until the player actually updates.
          Future<void>.delayed(
            const Duration(seconds: 1),
            () => _showDialog(force: true, version: version, notes: notes, storeUrl: storeUrl),
          );
        }
      case UpdateChoice.skip:
        if (skipKey != null) _s.write(StorageKeys.updateSkippedVersion, skipKey);
      case UpdateChoice.later:
      case null:
        if (!force) _snooze();
    }
  }

  Future<void> openStore([String? url]) async {
    final target =
        url ??
        (_ios
            ? (UpdateConfig.appStoreId != null
                  ? 'https://apps.apple.com/app/id${UpdateConfig.appStoreId}'
                  : 'https://apps.apple.com/search?term=${Uri.encodeComponent(AppConstants.shortName)}')
            : AppConstants.playStoreUrl);
    final market = Uri.parse('market://details?id=${AppConstants.packageName}');
    if (_android && await canLaunchUrl(market)) {
      await launchUrl(market);
    } else {
      await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void onClose() {
    _installSub?.cancel();
    super.onClose();
  }
}
