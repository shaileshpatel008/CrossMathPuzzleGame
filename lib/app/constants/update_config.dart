/// App update policy (Android: Google Play In-App Updates, iOS: App Store lookup).
///
/// Default is **optional**: players are offered the update, can postpone it,
/// and keep playing. A forced (blocking) update only happens when:
///  * the installed version is below `min_supported_version` in the remote
///    JSON at [remoteConfigUrl] (works for versions already in players' hands), or
///  * on Android, Play reports an in-app update priority >= [forceUpdatePriority]
///    (set per release via the Google Play Developer API), or
///  * you switch [mode] to [UpdateMode.force] (only affects builds shipped after that).
enum UpdateMode { optional, force }

class UpdateConfig {
  UpdateConfig._();

  static const UpdateMode mode = UpdateMode.optional;

  /// Optional JSON with `min_supported_version` per platform — see
  /// `app_update.json` in the repo root. Host it anywhere public (your website,
  /// Firebase Hosting, a public GitHub raw URL). Leave null to disable.
  static const String? remoteConfigUrl = null;

  /// After "Later", don't ask again for this long.
  static const Duration snoozeDuration = Duration(days: 3);

  /// Automatic checks on launch run at most this often.
  static const Duration minCheckInterval = Duration(hours: 12);

  /// Play in-app update priority (0–5) that turns an update into a forced one.
  static const int forceUpdatePriority = 4;

  /// iOS: App Store numeric id (shown in your App Store URL, e.g. id1234567890).
  /// Optional — used only as a fallback link when the lookup gives no URL.
  static const String? appStoreId = null;
}
