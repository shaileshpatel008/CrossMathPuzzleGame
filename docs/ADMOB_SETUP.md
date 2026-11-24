# AdMob – going live

The app already contains every ad placement (see README › Ad rules). Going live only needs your
AdMob **App IDs** and **ad unit IDs** in the code. Ad unit IDs are not secret — they ship inside the app.

## 1. Create the apps in AdMob

https://admob.google.com › **Apps › Add app** — do this once for **Android** and once for **iOS**.

- "Is the app listed on a supported app store?" → **Yes** and search for it if it's already on Google
  Play (any track that is public), otherwise **No** and link the store listing later
  (*App settings › Add app store details*). Ads serve fully only after the app is linked and AdMob's
  review ("App readiness") passes — usually a few days.
- App name: **CrossMath Puzzle**
- Copy the **App ID** (format `ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN`, with a **~**).

## 2. Create 5 ad units per platform

*Apps › CrossMath Puzzle › Ad units › Add ad unit.* Use the same five on Android and iOS
(10 IDs in total, format `ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN`, with a **/**).

| Format | Ad unit name | Settings | Where it shows in the app |
|---|---|---|---|
| **Banner** | `CM_Banner_Gameplay` | default (the app requests an adaptive size) | Bottom of Gameplay and Level map |
| **Interstitial** | `CM_Interstitial_LevelBreak` | Ad type: image + video | After every 2nd solved level from level 6 (≥90 s apart), and leaving a finished daily |
| **Rewarded** | `CM_Rewarded` | Reward amount **1**, reward item **Hint**; server-side verification off | +1 hint, second chance, ×3 level reward, ×2 daily gift, unlock a missed daily |
| **App open** | `CM_AppOpen` | default | Cold start from the 2nd session and on return after ≥30 s (max 1 per 4 h) |
| **Native advanced** | `CM_Native_Exit` | Ad type: image + video | Exit dialog on Home |

Frequency rules are enforced in code (`lib/app/constants/ad_config.dart`), so no AdMob frequency
capping is needed. Every non-rewarded format is hidden for Remove Ads / VIP buyers.

## 3. Privacy & messaging (required)

*AdMob › Privacy & messaging*:

1. **European regulations (GDPR)** › Create message › select both apps › add your privacy policy URL
   › **Publish**. Without it, ads won't serve in the EEA/UK. The app shows it automatically (Google UMP).
2. **US state regulations** › Create message › publish (recommended).
3. **iOS: IDFA explainer** › Create message › publish. UMP then shows Apple's tracking (ATT) prompt;
   the required `NSUserTrackingUsageDescription` is already in `Info.plist`.

## 4. app-ads.txt (protects your ad revenue)

1. In Play Console › *Store presence › Store settings*, set a **website** for the app
   (and the same in App Store Connect › Marketing URL).
2. Publish this file at the root of that website, e.g. `https://yourdomain.com/app-ads.txt`:
   ```
   google.com, pub-XXXXXXXXXXXXXXXX, DIRECT, f08c47fec0942fa0
   ```
   (your publisher id is in AdMob › *Settings › Account information*).
3. AdMob › *Apps › View all apps › app-ads.txt* shows when it's verified (can take ~24 h).

## 5. Put the IDs in the app

| What | Where |
|---|---|
| 10 ad unit IDs | `lib/app/constants/ad_config.dart` › the `_prodAndroid*` and `_prodIos*` constants |
| Android App ID | `android/app/src/main/AndroidManifest.xml` › `com.google.android.gms.ads.APPLICATION_ID` |
| iOS App ID | `ios/Runner/Info.plist` › `GADApplicationIdentifier` |
| Your test phones | `lib/app/constants/ad_config.dart` › `testDeviceIds` |

Debug builds keep using Google's test ads automatically; only release builds use your IDs.

**Your own phones:** install the release build, open the app, and look in the device log for
`Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("…"))` (Android) or
`GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"…" ]` (iOS).
Add that id to `testDeviceIds`. Never click live ads on your own devices — AdMob treats it as
invalid traffic and can limit or suspend the account.

## 6. Store declarations

- **Play Console › Policy › App content**: *Ads* → **Yes, my app contains ads**;
  *Advertising ID* → **Yes**, used for *Advertising or marketing* and *Analytics*;
  *Data safety* → declare **Device or other IDs** collected for advertising, shared with Google AdMob.
- **App Store Connect › App Privacy**: declare *Identifiers › Device ID* and *Usage data* used for
  third-party advertising.

## 7. AdMob account

- *Payments*: add your payment profile, tax info and bank account (payout threshold applies).
- New apps often show low fill for the first days — that's normal.

## Checklist

- [ ] Android + iOS apps created in AdMob, App IDs copied
- [ ] 5 ad units per platform created
- [ ] GDPR (+ US states, + iOS IDFA explainer) messages published
- [ ] app-ads.txt live on your website and verified
- [ ] IDs pasted into `ad_config.dart`, `AndroidManifest.xml`, `Info.plist`
- [ ] Own phones added to `testDeviceIds`
- [ ] Play Console "Contains ads" + Advertising ID + Data safety done
- [ ] Release build shows live ads on a non-test phone
